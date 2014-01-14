// Compile: gcc -o control control.m -framework IOKit -framework Cocoa

#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/IOHIDLib.h>
#import <IOKit/hidsystem/ev_keymap.h>
// The whole apple keymap
// http://www.opensource.apple.com/source/IOHIDFamily/IOHIDFamily-86.1/IOHIDSystem/IOKit/hidsystem/ev_keymap.h

static io_connect_t get_event_driver(void)
{
    static  mach_port_t sEventDrvrRef = 0;
    mach_port_t masterPort, service, iter;
    kern_return_t    kr;

    if (!sEventDrvrRef)
    {
        // Get master device port
        kr = IOMasterPort( bootstrap_port, &masterPort );
        check( KERN_SUCCESS == kr);

        kr = IOServiceGetMatchingServices( masterPort, IOServiceMatching( kIOHIDSystemClass ), &iter );
        check( KERN_SUCCESS == kr);

        service = IOIteratorNext( iter );
        check( service );

        kr = IOServiceOpen( service, mach_task_self(),
                            kIOHIDParamConnectType, &sEventDrvrRef );
        check( KERN_SUCCESS == kr );

        IOObjectRelease( service );
        IOObjectRelease( iter );
    }
    return sEventDrvrRef;
}

static void HIDPostAuxKey( const UInt8 auxKeyCode )
{
  NXEventData   event;
  kern_return_t kr;
  IOGPoint      loc = { 0, 0 };

  // Key press event
  UInt32      evtInfo = auxKeyCode << 16 | NX_KEYDOWN << 8;
  bzero(&event, sizeof(NXEventData));
  event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
  event.compound.misc.L[0] = evtInfo;
  kr = IOHIDPostEvent( get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE );
  check( KERN_SUCCESS == kr );

  // Key release event
  evtInfo = auxKeyCode << 16 | NX_KEYUP << 8;
  bzero(&event, sizeof(NXEventData));
  event.compound.subType = NX_SUBTYPE_AUX_CONTROL_BUTTONS;
  event.compound.misc.L[0] = evtInfo;
  kr = IOHIDPostEvent( get_event_driver(), NX_SYSDEFINED, loc, &event, kNXEventDataVersion, 0, FALSE );
  check( KERN_SUCCESS == kr );

}

int main(int argc, char *argv[]) {
  int toSend = NX_KEYTYPE_PLAY;
  unsigned int maxCmp = 15;

  if(argv[1] == NULL)
    toSend = NX_KEYTYPE_PLAY;
  else if(strncmp(argv[1], "play", maxCmp) == 0)
    toSend = NX_KEYTYPE_PLAY;
  else if(strncmp(argv[1], "mute", maxCmp) == 0)
    toSend = NX_KEYTYPE_MUTE;
  else if(strncmp(argv[1], "next", maxCmp) == 0)
    toSend = NX_KEYTYPE_FAST;
  else if(strncmp(argv[1], "prev", maxCmp) == 0)
    toSend = NX_KEYTYPE_REWIND;
  else if(strncmp(argv[1], "soundUp", maxCmp) == 0)
    toSend = NX_KEYTYPE_SOUND_UP;
  else if(strncmp(argv[1], "soundDown", maxCmp) == 0)
    toSend = NX_KEYTYPE_SOUND_DOWN;

  HIDPostAuxKey(toSend);
}
