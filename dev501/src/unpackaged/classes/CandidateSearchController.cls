public class CandidateSearchController {

    String searchText;
    List<Candidate__c> results;
    
    public String getSearchText(){
        return searchText;
    }
    
    public void setSearchText(String s){
        searchText = s;
    }
    
    public List<Candidate__c> getResults(){
        return results;
    }
    
    public PageReference doSearch() {
        results = (List<Candidate__c>)[FIND :searchText RETURNING Candidate__c(Email__c, First_Name__c, Last_Name__c)] [0];
        return null;
    }
 }