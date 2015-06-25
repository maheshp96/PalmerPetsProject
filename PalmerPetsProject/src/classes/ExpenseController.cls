public class ExpenseController {
    @AuraEnabled
    public static List<Expense__c> getExpenses() {
        return [SELECT id, name, milli__amount__c, milli__client__c, milli__date__c,
                milli__reimbursed__c, createdDate FROM Expense__c];
    }
    
    @AuraEnabled
    public static Expense__c saveExpense(Expense__c expense) {
        upsert expense;
        return expense;
    }
}