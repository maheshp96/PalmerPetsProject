public class DealViewerFrontController {
	String contactId = ApexPages.currentPage().getParameters().get('contactId');
    Contact contact;
   	List<DisplayOffers> dealsList;
    
    public List<DisplayOffers> getOffers() {
        if(dealsList==null){
            dealsList = new List<DisplayOffers>();
            for(Deal_Action__c item: [
                Select action__c, contact__r.name,deal__r.name from deal_action__c]){
                    dealsList.add(new DisplayOffers(item));
                }
        }
        return dealsList;
    }

    
    public class DisplayOffers{
        private Deal_Action__c dealAction;
        
        public DisplayOffers(Deal_Action__c item){
        	this.dealAction = item;    
        }

        private String status
        {
            get{ return dealAction.Action__c; }
            
        }
        private String icon{
            get { return 'defaultIcon';}
        }
        private String dealName
        {
            get{ return dealAction.Deal__r.name; }
        }
        private Date validThrough
        {
            get{ return dealAction.Deal__r.valid_through__c; }
        }
        public Decimal availableDeals{
            get { return dealAction.Deal__r.available_deals__c; }
        }
    }
}