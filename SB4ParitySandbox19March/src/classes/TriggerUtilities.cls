public class TriggerUtilities {

    public static Boolean HRBeforeTriggerCalled = false; // Keeps track of whether HRTriggerHandler has been called
    public static Boolean AccountBeforeTriggerCalled = false; // Keeps track of whether AccountTriggerHandler has been called
    
    // Method to set HRTriggerCalled static variable, called from the HRTriggerHandler apex trigger
    public static void setHRBeforeTriggerCalled() {
        HRBeforeTriggerCalled = true;
    }
    
    // Method to set AccountTriggerCalled static variable, called from the AccountTriggerHandler apex trigger
    public static void setAccountBeforeTriggerCalled() {
        AccountBeforeTriggerCalled = true;
    }
    
    // Method to reset AccountTriggerCalled static variable
    public static void resetAccountBeforeTriggerCalled() {
        AccountBeforeTriggerCalled = false;
    }
}