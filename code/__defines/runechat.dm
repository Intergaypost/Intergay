/// How long the chat message's spawn-in animation will occur for
#define CHAT_MESSAGE_SPAWN_TIME (0.2 SECONDS)
/// How long the chat message will exist prior to any exponential decay
#define CHAT_MESSAGE_LIFESPAN (5 SECONDS)
/// How long the chat message's end of life fading animation will occur for
#define CHAT_MESSAGE_EOL_FADE (0.7 SECONDS)
/// Grace period for fade before we actually delete the chat message
#define CHAT_MESSAGE_GRACE_PERIOD (0.2 SECONDS)
/// Factor of how much the message index (number of messages) will account to exponential decay
#define CHAT_MESSAGE_EXP_DECAY 0.7
/// Factor of how much height will account to exponential decay
#define CHAT_MESSAGE_HEIGHT_DECAY 0.9
/// Approximate height in pixels of an 'average' line, used for height decay
#define CHAT_MESSAGE_APPROX_LHEIGHT 13
/// Max width of chat message in pixels
#define CHAT_MESSAGE_WIDTH 160
/// Maximum characters displayed in a runechat bubble
#define CHAT_MESSAGE_MAX_LENGTH 110

/// Base layer of chat elements
#define CHAT_LAYER 1
/// Highest possible layer of chat elements
#define CHAT_LAYER_MAX 2
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP 0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z ((CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP)

/// Message flag indicating emote formatting (italics, emote styling)
#define EMOTE_MESSAGE (1<<0)

/// Runechat rendering plane (above lighting so text is visible in dark)
#ifndef RUNECHAT_PLANE
#define RUNECHAT_PLANE ABOVE_LIGHTING_PLANE
#endif

/// Color ranges for colorize_string
#define CM_COLOR_SAT_MIN 0.6
#define CM_COLOR_SAT_MAX 0.7
#define CM_COLOR_LUM_MIN 0.65
#define CM_COLOR_LUM_MAX 0.75

#define SS_PRIORITY_RUNECHAT 90
