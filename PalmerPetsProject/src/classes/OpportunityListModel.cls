public class OpportunityListModel {

	private List<Opportunity> opportunities;
	
	public OpportunityListModel(){
		init();
	}
	
	private void init(){
		opportunities = (List<Opportunity>) setCon.getRecords();
	}
	
	public ApexPages.StandardSetController setCon{
		get {
			if(setCon==null){
				setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
				[SELECT Id, Name, CloseDate FROM Opportunity]));
			}
			return setCon;
		}
		set;
	}
	
	@AuraEnabled
	public List<Opportunity> getOpportunities(){
		return opportunities;
	}
}