/// AppStrings centralizes all user-facing strings across the app.
class AppStrings {
  AppStrings._();

  // Common
  static const String appName = 'Meeem Rider';
  static const String appTagline = 'Fast, Reliable Partner on the Move';
  static const String currencySymbol = 'Nle';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String submit = 'Submit';
  static const String retry = 'Retry';
  static const String back = 'Back';
  static const String save = 'Save';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String loading = 'Loading...';

  // Auth & Login
  static const String welcomeBack = 'Welcome Back, Partner';
  static const String loginSubtitle = 'Sign in to access your deliveries and earnings';
  static const String loginWithEmail = 'Email & Password';
  static const String loginWithPhone = 'Phone & OTP';
  static const String phoneNumber = 'Phone Number';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String resetPasswordSubtitle = 'Enter your email or phone to receive a reset code';
  static const String newPassword = 'New Password';
  static const String confirmPassword = 'Confirm Password';
  static const String sendResetCode = 'Send Reset Code';
  static const String sendOtp = 'Send Verification Code';
  static const String verifyOtp = 'Verify OTP';
  static const String otpSubtitle = 'Enter the 6-digit code sent to';
  static const String resendOtp = 'Resend Code';
  static const String resendIn = 'Resend in';
  static const String registerTitle = 'Rider Registration';
  static const String registerSubtitle = 'Complete your profile to start delivering';
  static const String fullName = 'Full Name';
  static const String email = 'Email Address';

  // Onboarding Wizard
  static const String onboardingTitle = 'Rider Onboarding';
  static const String stepPersonal = 'Personal Info';
  static const String stepDocuments = 'Documents';
  static const String stepVehicle = 'Vehicle';
  static const String stepZones = 'Operating Zones';
  static const String stepPayout = 'Payout Details';
  static const String uploadProfilePhoto = 'Upload Profile Photo';
  static const String takePhoto = 'Take Photo';
  static const String chooseGallery = 'Choose from Gallery';
  static const String nationalId = 'National ID / Passport';
  static const String driverLicense = "Driver's License";
  static const String vehicleInsurance = 'Vehicle Insurance';
  static const String vehicleType = 'Vehicle Type';
  static const String vehiclePlate = 'License Plate Number';
  static const String vehicleModel = 'Vehicle Make & Model';
  static const String twoWheeler = '2-Wheeler (Motorcycle / Scooter)';
  static const String threeWheeler = '3-Wheeler (Auto Rickshaw / TukTuk)';
  static const String fourWheeler = '4-Wheeler (Car / Van / Delivery Truck)';
  static const String operatingZones = 'Preferred Operating Zones';
  static const String selectZonesSubtitle = 'Choose districts you prefer to receive orders from';
  static const String payoutInfo = 'Payout Information';
  static const String bankAccount = 'Bank Account';
  static const String mobileMoney = 'Mobile Money';
  static const String bankName = 'Bank Name';
  static const String accountNumber = 'Account Number';
  static const String accountHolder = 'Account Holder Name';
  static const String mobileMoneyProvider = 'Mobile Money Provider';
  static const String mobileMoneyNumber = 'Mobile Money Phone Number';
  static const String beneficiaryName = 'Beneficiary Name';
  static const String nextStep = 'Next Step';
  static const String completeOnboarding = 'Submit Application';

  // Dashboard
  static const String youAreOnline = "You're Online";
  static const String youAreOffline = "You're Offline";
  static const String goOnlineToEarn = 'Go online to start receiving delivery orders';
  static const String onlineFindingOrders = 'Searching for nearby delivery requests...';
  static const String todaysEarnings = "Today's Earnings";
  static const String completedOrders = 'Completed';
  static const String acceptanceRate = 'Acceptance';
  static const String rating = 'Rating';
  static const String onlineHours = 'Online Hours';
  static const String accountStatus = 'Account Status';
  static const String totalDeliveries = 'Total Deliveries';
  static const String liveGpsTracking = 'GPS Tracking Active';

  // Incoming Order Alert
  static const String newOrderRequest = 'New Delivery Request!';
  static const String estimatedEarnings = 'Estimated Earnings';
  static const String pickupFrom = 'Pickup from';
  static const String deliverTo = 'Deliver to';
  static const String totalDistance = 'Total Distance';
  static const String estTime = 'Est. Time';
  static const String acceptOrder = 'Accept Order';
  static const String declineOrder = 'Decline';

  // Active Order Flow (5 Steps)
  static const String activeOrder = 'Active Delivery';
  static const String stepAccepted = 'Heading to Pickup Store';
  static const String stepAtPickup = 'Arrived at Store';
  static const String stepPickedUp = 'Order Picked Up';
  static const String stepOutForDelivery = 'On the Way to Customer';
  static const String stepDelivered = 'Delivered';
  static const String navigateToPickup = 'Navigate to Store';
  static const String navigateToDropoff = 'Navigate to Customer';
  static const String swipeArrivedPickup = 'Swipe when Arrived at Store';
  static const String swipeConfirmPickup = 'Swipe to Confirm Order Picked Up';
  static const String swipeStartDelivery = 'Swipe to Start Delivery';
  static const String swipeArrivedCustomer = 'Swipe when Arrived at Customer';
  static const String swipeCompleteDelivery = 'Swipe to Complete Delivery';
  static const String customerContact = 'Contact Customer';
  static const String vendorContact = 'Contact Vendor';
  static const String callCustomer = 'Call Customer';
  static const String callVendor = 'Call Vendor';
  static const String messageCustomer = 'Message Customer';
  static const String orderItems = 'Order Items';
  static const String specialInstructions = 'Special Instructions';
  static const String proofOfDelivery = 'Proof of Delivery';
  static const String uploadProofPhoto = 'Take Dropoff Photo (Optional)';
  static const String enterCustomerOtp = 'Enter Customer Delivery OTP';

  // Navigation
  static const String openInGoogleMaps = 'Google Maps';
  static const String openInAppleMaps = 'Apple Maps';
  static const String chooseMapApp = 'Choose Navigation App';

  // Earnings
  static const String wallet = 'Wallet & Earnings';
  static const String availableForPayout = 'Available Balance';
  static const String cashOut = 'Cash Out';
  static const String daily = 'Daily';
  static const String weekly = 'Weekly';
  static const String monthly = 'Monthly';
  static const String baseFare = 'Base Delivery Pay';
  static const String customerTips = 'Tips';
  static const String surgeBonus = 'Surge & Incentives';
  static const String payoutHistory = 'Payout History';

  // Profile & Documents
  static const String profile = 'My Profile';
  static const String vehicleDetails = 'Vehicle Details';
  static const String documents = 'Documents & Verification';
  static const String appSettings = 'Settings';
  static const String darkMode = 'Dark Mode';
  static const String helpSupport = 'Help & Support';
  static const String termsPrivacy = 'Terms & Privacy';
  static const String logout = 'Log Out';
  static const String logoutConfirm = 'Are you sure you want to log out?';

  // Document Statuses
  static const String docVerified = 'Verified';
  static const String docPending = 'Under Review';
  static const String docRejected = 'Action Required';
}
