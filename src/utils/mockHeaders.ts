import { IOSClassInfo } from "../types";

export const COMMON_IOS_HEADERS: IOSClassInfo[] = [
  {
    className: "UIViewController",
    framework: "UIKit",
    description: "Base view controller class managing view lifecycle, navigation, and presentation in iOS.",
    commonMethods: [
      "- (void)viewDidLoad",
      "- (void)viewWillAppear:(BOOL)animated",
      "- (void)viewDidAppear:(BOOL)animated",
      "- (void)viewWillDisappear:(BOOL)animated",
      "- (BOOL)prefersStatusBarHidden"
    ],
    suggestedTweakIdeas: [
      "Custom background color on all view controllers",
      "Inject custom watermark overlay into views",
      "Intercept presentation and log lifecycle steps"
    ]
  },
  {
    className: "SBIconView",
    framework: "SpringBoard",
    description: "SpringBoard class responsible for rendering iOS home screen app icons and touch badges.",
    commonMethods: [
      "- (void)setLabelHidden:(BOOL)hidden",
      "- (void)setHighlighted:(BOOL)highlighted",
      "- (void)setIcon:(id)icon",
      "- (void)setBadge:(id)badge"
    ],
    suggestedTweakIdeas: [
      "Hide icon labels globally",
      "Add custom glow effect to highlighted icons",
      "Override badge counts or badge colors"
    ]
  },
  {
    className: "SBLockScreenManager",
    framework: "SpringBoard",
    description: "SpringBoard manager controlling iOS Lock Screen states, passcode unlock, and wake animations.",
    commonMethods: [
      "- (void)lockUIFromSource:(int)source withOptions:(id)options",
      "- (void)unlockUIFromSource:(int)source withOptions:(id)options",
      "- (BOOL)isUILocked",
      "- (void)_finishUIUnlockAndDismiss"
    ],
    suggestedTweakIdeas: [
      "Custom unlock animations",
      "Skip passcode UI under specific conditions",
      "Trigger custom haptic feedback on wake"
    ]
  },
  {
    className: "CCUIModuleCollectionView",
    framework: "ControlCenter",
    description: "Control Center grid component holding quick toggle modules (Wi-Fi, Bluetooth, Torch, Brightness).",
    commonMethods: [
      "- (void)layoutSubviews",
      "- (void)setCompact:(BOOL)compact"
    ],
    suggestedTweakIdeas: [
      "Expand Control Center module layout rows",
      "Apply custom dark neon theme to CC modules"
    ]
  },
  {
    className: "SpringBoard",
    framework: "SpringBoard",
    description: "Main SpringBoard application delegate handling global system gestures, notifications, and status bar.",
    commonMethods: [
      "- (void)applicationDidFinishLaunching:(id)application",
      "- (void)_rebootNow",
      "- (void)_respring",
      "- (void)takeScreenshot"
    ],
    suggestedTweakIdeas: [
      "Add instant triple-tap screenshot shortcut",
      "Show custom welcome alert on device boot"
    ]
  },
  {
    className: "SBVolumeControl",
    framework: "SpringBoard",
    description: "SpringBoard volume HUD controller handling hardware volume key presses and HUD display.",
    commonMethods: [
      "- (void)increaseVolume",
      "- (void)decreaseVolume",
      "- (void)_presentVolumeHUDWithVolumeLevel:(float)level"
    ],
    suggestedTweakIdeas: [
      "Custom volume step size (fine-grained control)",
      "Replace stock volume HUD with custom minimal bar",
      "Play custom haptic on max/min volume limit"
    ]
  },
  {
    className: "NCNotificationListView",
    framework: "UserNotifications",
    description: "Notification Center list view rendering grouped lockscreen banners and system alerts.",
    commonMethods: [
      "- (void)insertNotificationRequest:(id)request",
      "- (void)clearAllNotificationRequests"
    ],
    suggestedTweakIdeas: [
      "Add 'Clear All' button to lock screen notifications",
      "Apply custom acrylic blur background to notifications"
    ]
  },
  {
    className: "SBMainSwitcherViewController",
    framework: "SpringBoard",
    description: "SpringBoard App Switcher multi-tasking card view controller.",
    commonMethods: [
      "- (void)setSwitcherWindowVisible:(BOOL)visible",
      "- (void)_dismissSwitcherAnimated:(BOOL)animated"
    ],
    suggestedTweakIdeas: [
      "Add 'Kill All Apps' gesture button to App Switcher",
      "Grid card view layout for app switcher cards"
    ]
  },
  {
    className: "UIWindow",
    framework: "UIKit",
    description: "Core window object serving as root container for views and touch dispatching.",
    commonMethods: [
      "- (void)becomeKeyWindow",
      "- (void)makeKeyAndVisible",
      "- (void)sendEvent:(id)event"
    ],
    suggestedTweakIdeas: [
      "Global touch event logger or tap visualizer overlay",
      "Inject floating HUD overlay over all apps"
    ]
  }
];

export const INITIAL_DEFAULT_PROJECT = {
  id: "proj-lockscreen-glow",
  name: "NeonLock Tweak",
  version: "1.0.0",
  author: "CyberDev",
  bundleId: "com.workshop.neonlock",
  projectType: "jailbreak_tweak" as const,
  targetProcess: "SpringBoard",
  tweakFilter: "com.apple.springboard",
  description: "A neon SpringBoard lock screen and view controller hook with custom logs and color shifts.",
  createdAt: "2026-08-05T12:00:00Z",
  updatedAt: "2026-08-05T12:00:00Z",
  blocks: [
    {
      id: "block-1",
      type: "hook" as const,
      title: "🪝 Hook UIViewController",
      position: { x: 100, y: 120 },
      targetClass: "UIViewController",
      targetMethod: "viewDidAppear:",
      isClassMethod: false,
      returnType: "void",
      methodParameters: "(BOOL)animated",
      childrenBlockIds: ["block-2"]
    },
    {
      id: "block-2",
      type: "orig" as const,
      title: "📞 Call Original",
      position: { x: 140, y: 260 },
      nextBlockId: "block-3"
    },
    {
      id: "block-3",
      type: "log" as const,
      title: "📝 Log Message",
      position: { x: 140, y: 380 },
      message: "The Workshop tweak injected into UIViewController viewDidAppear!",
      logLevel: "NSLog" as const,
      nextBlockId: "block-4"
    },
    {
      id: "block-4",
      type: "modify_property" as const,
      title: "⚙️ Modify Property",
      position: { x: 140, y: 500 },
      targetObject: "self.view",
      propertyName: "tintColor",
      value: "[UIColor systemGreenColor]",
      nextBlockId: "block-5"
    },
    {
      id: "block-5",
      type: "notification" as const,
      title: "🔔 Show Alert",
      position: { x: 140, y: 620 },
      titleText: "The Workshop",
      bodyText: "Tweak active on view presentation!"
    }
  ]
};
