
#define TIMER_NO_INVOKE_WARNING 600 //number of byond ticks that are allowed to pass before the timer subsystem thinks it hung on something

//For servers that can't do with any additional lag, set this to none in flightpacks.dm in subsystem/processing.
#define FLIGHTSUIT_PROCESSING_NONE 0
#define FLIGHTSUIT_PROCESSING_FULL 1

#define INITIALIZE_HINT_NORMAL   0  //Nothing happens
#define INITIALIZE_HINT_LATELOAD 1  //Call LateInitialize
#define INITIALIZE_HINT_QDEL     2  //Call qdel on the atom

#define INITIALIZATION_INSSATOMS      0	//New should not call Initialize
#define INITIALIZATION_INSSATOMS_LATE 1	//New should not call Initialize; after the first pass is complete (handled differently)
#define INITIALIZATION_INNEW_MAPLOAD  2	//New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR  3	//New should call Initialize(FALSE)

//type and all subtypes should always call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
	..();\
	if(!(atom_flags & ATOM_FLAG_INITIALIZED)) {\
		args[1] = TRUE;\
		SSatoms.InitAtom(src, args);\
	}\
}

// Subsystem init_order, from highest priority to lowest priority
// Subsystems shutdown in the reverse of the order they initialize in
// The numbers just define the ordering, they are meaningless otherwise.

#define INIT_ORDER_ANTAGS 20
#define INIT_ORDER_SKYBOX 19
#define INIT_ORDER_DBCORE 18
#define INIT_ORDER_BLACKBOX 17
#define INIT_ORDER_SERVER_MAINT 16
#define INIT_ORDER_JOBS 15
#define INIT_ORDER_EVENTS 14
#define INIT_ORDER_TICKER 13
#define INIT_ORDER_MAPPING 12
#define INIT_ORDER_ATOMS 11
#define INIT_ORDER_LANGUAGE 10
#define INIT_ORDER_MACHINES 9
#define INIT_ORDER_SHUTTLE 3
#define INIT_ORDER_TIMER 1
#define INIT_ORDER_DEFAULT 0
#define INIT_ORDER_AIR -1
#define INIT_ORDER_MINIMAP -2
#define INIT_ORDER_ASSETS -3
// Amount of time(ds) MAX to send per asset, if this get exceeded we cancel the sleeping.
#define ASSET_CACHE_SEND_TIMEOUT 7
// When sending mutiple assets, how many before we give the client a quaint little sending resources message
#define ASSET_CACHE_TELL_CLIENT_AMOUNT 8
// When passively preloading assets, how many to send at once?
#define ASSET_CACHE_PRELOAD_CONCURRENT 3
#define INIT_ORDER_ICON_SMOOTHING -5
#define INIT_ORDER_OVERLAY -6
#define INIT_ORDER_XKEYSCORE -10
#define INIT_ORDER_STICKY_BAN -10
#define INIT_ORDER_LIGHTING -20
#define INIT_ORDER_SQUEAK -40
#define INIT_ORDER_PERSISTENCE -100
#define INIT_OPEN_SPACE -150
#define INIT_BAY_LEGACY -200
#define INIT_ORDER_CRAFT -175
#define INIT_ORDER_CHAT	-185
#define SS_INIT_CHAT     -90 // Should be lower to ensure chat remains smooth during init.

// Subsystem init_order, from highest priority to lowest priority
// Subsystems shutdown in the reverse of the order they initialize in
// The numbers just define the ordering, they are meaningless otherwise.

#define SS_INIT_INPUT            20
#define SS_INIT_EARLY            19

#define SS_INIT_GARBAGE          18
#define SS_INIT_CHEMISTRY        17
#define SS_INIT_PLANTS           16
#define SS_INIT_ANTAGS           15
#define SS_INIT_LORE             14
#define SS_INIT_MISC             13
#define SS_INIT_SKYBOX           12
#define SS_INIT_MAPPING          11
#define SS_INIT_DEPARTMENTS      10
#define SS_INIT_JOBS             9
#define SS_INIT_CHAR_SETUP       8
#define SS_INIT_CIRCUIT          7
#define SS_INIT_GRAPH            6
#define SS_INIT_OPEN_SPACE       5
#define SS_INIT_ATOMS            4
#define SS_INIT_MACHINES         3
#define SS_INIT_ICON_UPDATE      2
#define SS_INIT_OVERLAY          1
#define SS_INIT_DEFAULT          0
#define SS_INIT_AIR             -1
#define SS_INIT_MISC_LATE       -2
#define SS_INIT_MISC_CODEX      -3
#define SS_INIT_ALARM           -4
#define SS_INIT_SHUTTLE         -5
#define SS_INIT_GOALS           -5
#define SS_INIT_LIGHTING        -6
#define SS_INIT_ZCOPY           -7
#define SS_INIT_XENOARCH        -10
#define SS_INIT_BAY_LEGACY      -12
#define SS_INIT_TICKER          -20
#define SS_INIT_UNIT_TESTS      -100

// SS runlevels

#define RUNLEVEL_INIT 0
#define RUNLEVEL_LOBBY 1
#define RUNLEVEL_SETUP 2
#define RUNLEVEL_GAME 4
#define RUNLEVEL_POSTGAME 8

#define RUNLEVELS_DEFAULT (RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME)
