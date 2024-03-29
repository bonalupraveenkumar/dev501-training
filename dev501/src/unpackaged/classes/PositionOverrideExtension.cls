public class PositionOverrideExtension{
    // Simple extension to demonstrate overriding the save function, and how to determine if the record
    //   should be updated or inserted during the save operation.  This extension could be used on both
    //   an Edit override and a New override simultaneously.
    
    private Position__c pos;
    // Will help us determine whether to do Insert or Update upon Save
    private Boolean bUpdate;
    // Declare standardController controller
    private ApexPages.StandardController controller;
    // Declare a string property to hold a message value
    public String myMessage { get; set; }
    
    // The extension constructor initializes the private member
    // variable pos by using the getRecord method from the standard
    // controller.
    public PositionOverrideExtension(ApexPages.StandardController stdController) {
    	controller = stdController;
        this.pos= (Position__c)stdController.getRecord();
        bUpdate = pos.id == null ? false : true;
    }
    
    // This function is called from a commandButton on the page
    public PageReference SayHelloWorld(){
        // call this custom function from your visualforce page
        myMessage = 'Hello World!';

        // We're not redirecting the user to a different page so we just say return null
        return null;
    }
    
    public PageReference mySave(){
    	// This is contrived unless there is something to do special in the update or insert you're trying to do
    	//	if you're not doing anything special in the save then just use the standardController.save()
        if (bUpdate){
        	// We could add custom behavior here
            update pos;
        } else {
        	// We could add custom behavior here
            insert pos;
        }
        
        // Use the standardController to navigate : avoid string-based PageReference redirects if possible
        return controller.view();
    }
   
}