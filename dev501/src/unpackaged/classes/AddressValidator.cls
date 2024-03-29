public class AddressValidator {
	
	static final StrikeIronInfo__c info = [select userid__c,password__c from strikeironinfo__c where active__c = true limit 1];
	
  //Future annotation to mark the method as async.
  // TODO: Mark this method with the annotation necessary to make it able to be called asynchronously
  @FUTURE 
  public static void validateAddress(String id) {
  	String msg = '';
 	try {
	 	Candidate__c cand = [select AsyncValidationFlag__c, Street_Address_1__c, Street_Address_2__c, city__c, state_Province__c, zip_postal_code__c, country__c, valid_us_address__c, county__c, congress_district__c, latitude__c, longitude__c, address_error__c from candidate__c where id=:id];										
	 	msg += 'candidate=' + cand + '\n\n';
	 	msg += 'info=' + info + '\n\n';
	 	
	    //construct an HTTP request
	    HttpRequest req = new HttpRequest();
	    String endpoint = 'http://ws.strikeiron.com/StrikeIron/USAddressVerification4_0/USAddressVerification/VerifyAddressUSA?';
	    String uId = 'LicenseInfo.RegisteredUser.UserID=' + EncodingUtil.urlEncode(info.userid__c,'UTF-8');
	    String pw = '&LicenseInfo.RegisteredUser.Password=' + info.password__c;
	    String street1 = '&VerifyAddressUSA.addressLine1=';
	    street1 += cand.Street_Address_1__c != null ? EncodingUtil.urlEncode(cand.Street_Address_1__c,'UTF-8') : '';
	    String street2 = '&VerifyAddressUSA.addressLine2=';
	    street2 += cand.Street_Address_2__c != null ?  EncodingUtil.urlEncode(cand.Street_Address_2__c,'UTF-8') : '';
	    String citystatezip = '&VerifyAddressUSA.city_state_zip=';
	    citystatezip += cand.City__c != null ? EncodingUtil.urlEncode(cand.City__c + ' ','UTF-8') : '';
	    citystatezip += cand.State_Province__c != null ?  EncodingUtil.urlEncode(cand.State_Province__c + ' ','UTF-8') : '';
	    citystatezip += cand.Zip_Postal_Code__c != null ? EncodingUtil.urlEncode(cand.Zip_Postal_Code__c,'UTF-8') : '';
	    
	    // now combine all the params into one string (named endpoint)
	    endpoint += uId + pw + street1 + street2 + citystatezip + '&VerifyAddressUSA.casing=Proper';
	    
	    msg += 'endpoint=' + endpoint + '\n';

	    // TODO: The following 5 tasks can be accomplished in 4-5 lines of code
	    // TODO: set the endpoint of the HTTPRequest variable named req.  The HTTPRequest instance has already been declared for you in the lines above.
	    req.setEndpoint(endpoint);
	    // TODO: set the method of the HTTPRequest (req) to GET
	    req.setMethod('GET');
	    // TODO: instantiate an instance of the HTTP class and call it http
	    Http http = new Http();
	    // TODO: instantiate an HTTPResponse instance and call it res
	    HttpResponse res = new HttpResponse();
	    // TODO: send the HTTPRequest, req, using your HTTP class instance and captures the HTTPResponse using your HTTPResponse instance variable, res
	    res = http.send(req);
		
    	if (res.getStatusCode() == 200) {
	      //update candidate
	      
	      // now let's actually do something useful with the response
	      XMLDom doc = new XMLDom(res.getBody());
	      
	      // get the main part of the address results out of the xml response
	      XMLDom.Element result = doc.getElementByTagName('VerifyAddressUSAResult');
	      
	      // find out if the address is valid
	      if (result.getValue('AddressStatus') == 'Valid'){
	      	// let's update the Candidate address info with the Country, Zip+4, County, CongressDistrict, and Lat & Long
	      	cand.valid_us_address__c = true;
	      	cand.Country__c = 'US';
	      	cand.Zip_Postal_Code__c = result.getValue('ZipPlus4');
	      	cand.County__c = result.getValue('County');
	      	cand.Congress_District__c = result.getValue('CongressDistrict');
	      	cand.Latitude__c = Double.valueOf(result.getValue('Latitude'));
	      	cand.Longitude__c = Double.valueOf(result.getValue('Longitude'));
	      	cand.address_error__c = '';
	      } else {
	      	cand.County__c = '';
	      	cand.Congress_District__c = '';
	      	cand.Latitude__c = null;
	      	cand.Longitude__c = null;
	      	cand.address_error__c = result.getValue('AddressErrorNumber') + ' - '  +result.getValue('AddressErrorMessage');
	      	cand.valid_us_address__c = false;
	      }
	      cand.asyncvalidationflag__c = true;
	      msg += 'async updated candidate=' + cand + '\n';
	      update cand;
	    } else {
	      System.debug('Callout failed: ' + res);
	      msg += 'STATUS:'+res.getStatus();
		  msg += '\nSTATUS_CODE:'+res.getStatusCode();
		  msg += '\nBODY: '+res.getBody();
		  Error_Log__c log = new Error_Log__c();
		  log.trace__c = msg;
		  insert log;
	    } 
		
	} catch(Exception e) {
		System.debug('ERROR: '+ e);
		Error_Log__c log = new Error_Log__c();
	    log.trace__c = msg + '\n' + e.getCause() + '\n' + e.getMessage();
	    insert log;
	}
  }
  
}