//----------------------------------------------------------
//Author: Sunil Kumar(sunil02kumar@gmail.com)
//Purpose: Test class for LightningJSONDataTableController
//********changes logs*********
//-------------------------------------------------------
@IsTest
private class LightningJSONDataTableControllerTest{

    private testmethod static void testmethod1(){
        List<Account> acclist=new List<Account>();
        for(integer i=0;i<200;i++){
            Account acc=new Account(name='sunil'+i,type='direct',industry='Other',AnnualRevenue=i);
            acclist.add(acc);
            
        }
        insert acclist;
        string JSONData=LightningJSONDataTableController.generateDataSet('Account','Name,Type,Industry,Createddate,AnnualRevenue,Rating','Name,Type,Industry,Created Date,AnnualRevenue,Rating','Name','LastModifiedDate DESC','isDeleted=false','100');
    }

}