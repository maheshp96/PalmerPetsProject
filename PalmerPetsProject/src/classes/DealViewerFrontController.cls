public class DealViewerFrontController {

    public Contact contactperson { get; set; }

    public static String contactId = ApexPages.currentPage().getParameters().get('contactId');
    public List<DisplayOffers> dealsList;
    public static Map<String, String> dealActionMap = getDealActions();
    
    public static Map<String,String> getDealActions(){
        Map<String, String> dealActionListMap = new Map<String,String>();
        for(Deal_Action__c dealAction: [
                Select d.SystemModstamp, d.OwnerId, d.Name,
                d.LastViewedDate, d.LastReferencedDate, d.LastModifiedDate, 
                d.LastModifiedById, d.LastActivityDate, d.IsDeleted, d.Id, 
                d.CreatedDate, d.CreatedById, d.Contact__c, d.Action__c, d.Deal__r.Name 
                From Deal_Action__c d
                Where d.Contact__r.Id=:contactId
            ])
                {
                    //dealActionListMap  = new Map<String, String>();
                    String dealName = dealAction.Deal__r.Name;
                    dealActionListMap  .put(dealName, dealAction.Action__c);
                }
           return dealActionListMap;
    }

    public Contact getContact(){
        return [Select c.Title, c.SystemModstamp, c.Salutation, c.ReportsToId, c.PhotoUrl, c.Phone, c.OwnerId, c.OtherStreet, c.OtherState, c.OtherPostalCode, c.OtherPhone, c.OtherLongitude, c.OtherLatitude, c.OtherCountry, c.OtherCity, c.OtherAddress, c.Name, c.MobilePhone, c.MasterRecordId, c.MailingStreet, c.MailingState, c.MailingPostalCode, c.MailingLongitude, c.MailingLatitude, c.MailingCountry, c.MailingCity, c.MailingAddress, c.LeadSource, c.LastViewedDate, c.LastReferencedDate, c.LastName, c.LastModifiedDate, c.LastModifiedById, c.LastCUUpdateDate, c.LastCURequestDate, c.LastActivityDate, c.JigsawContactId, c.Jigsaw, c.IsEmailBounced, c.IsDeleted, c.Id, c.HomePhone, c.FirstName, c.Fax, c.EmailBouncedReason, c.EmailBouncedDate, c.Email, c.Description, c.Department, c.Deals_Rejected__c, c.Deals_Accepted__c, c.CreatedDate, c.CreatedById, c.CleanStatus, c.Birthdate, c.AssistantPhone, c.AssistantName, c.AccountId, c.Acceptance_Rate__c From Contact c where c.Id=:contactId];
    }
    
    public List<DisplayOffers> getOffers() {
        contactperson = getContact();        
        if(dealsList==null){
            dealsList = new List<DisplayOffers>();
            for(Deal__c item: [
                //Select action__c, contact__r.name,deal__r.name from deal_action__c
                // old query to get the dealActions and deals join from dealActions object.
                Select Name,(Select Action__c From Deal_Actions__r),Valid_Through__c,Available_Deals__c From Deal__c d
                ])
                {
                    dealsList.add(new DisplayOffers(item));
                }
            for(Deal_Action__c dealAction: [
                Select d.SystemModstamp, d.OwnerId, d.Name,
                d.LastViewedDate, d.LastReferencedDate, d.LastModifiedDate, 
                d.LastModifiedById, d.LastActivityDate, d.IsDeleted, d.Id, 
                d.CreatedDate, d.CreatedById, d.Contact__c, d.Action__c, d.Deal__r.Name 
                From Deal_Action__c d
                Where d.Contact__r.Id=:contactId
            ])
                {
                    dealActionMap = new Map<String, String>();
                    String dealName = dealAction.Deal__r.Name;
                    dealActionMap.put(dealName, dealAction.Action__c);
                }            
        }
        return dealsList;
    }

    public void rejectOffer() {
    	//Insert a new record for rejected offer instance in the Deal_Action table.
    	Deal_Action__c dealAction = new Deal_Action__c();
    	
        System.debug(contactperson);
        contactperson.Deals_Rejected__c+=1;
        update contactperson;
    }


    public void acceptOffer() {
        System.debug(contactperson);
        contactperson.Deals_Accepted__c+=1;
        update contactperson;
    }


    
    public class DisplayOffers{
        private Deal__c deal;
        
        public DisplayOffers(Deal__c item){
                this.deal = item;    
        }

        public String status
        {
            get{ 
                if(dealActionMap.containsKey(deal.Name)){
                    //Deal_Action__c dealAction = (Deal_Action__c)dealActionMap.get(deal.Name);
                    //return dealAction.Action__c;
                    return dealActionMap.get(deal.Name) + 'ed';
                }
                else
                {
                    //Deal_Action__c da = (Deal_Action__c)dealActionMap.get(deal.Name);
                        //return da.Action__c;
                    return 'Available';
                }
            }
        }
        
        public String icon{
            get { return 'defaultIcon';}
        }
        
        public String dealName
        {
            get{ return deal.name; }
        }
        
        public Date validThrough
        {
            get{ return deal.Valid_Through__c; }
        }
        public Decimal availableDeals{
            get { return deal.available_deals__c; }
        }
        
        public Boolean isRejectable
        {
            get
            { 
                if(dealActionMap.get(deal.Name)==null)
                    return false;
                else
                    return true;
            }
        }
        
        public Boolean isAcceptable
        {
            get
            { 
                if(dealActionMap.get(deal.Name)==null)
                    return false;
                else
                    return true;
            }
        }
    }
}