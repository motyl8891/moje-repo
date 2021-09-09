/**
 * @File Name          : OC_AN_InternalAutomationSchedulerTest
 * @Description        : Test class for OC_AN_InternalAutomationScheduler.
 * @Author             : IBM
 * @Group              : OmniChannel - Service
 * @Release            : R2106
 * @Created Date       : 20th May 2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0        2021-05-20                 IBM                   Initial Version
 **/


@Istest
public class OC_AN_InternalAutomationSchedulerTest{

	public static final String TEST_CLASS_NAME = 'TestScheduleClass';

	public class TestScheduleClass implements Schedulable{
		public void execute(SchedulableContext param1){
		}
	}

    @IsTest
	public static void construction(){
        Map<String, String>  testList = new Map<String, String> ();
        OC_AN_InternalAutomationScheduler ias = new OC_AN_InternalAutomationScheduler(testList);
    }
    

	@IsTest
	public static void schedule(){
		TestScheduleClass testClass = new TestScheduleClass();

		Test.startTest();
		OC_AN_InternalAutomationScheduler.scheduleInSeconds(testClass, 200, TEST_CLASS_NAME);
		List<CronTrigger> jobs = [SELECT Id
		                          FROM CronTrigger
		                          WHERE CronJobDetail.Name = :(OC_AN_InternalAutomationScheduler.SCHEDULED_JOB_NAME_PRESET + TEST_CLASS_NAME)];
		System.assertEquals(1, jobs.size(), 'One schedule exsists');
		OC_AN_InternalAutomationScheduler.deleteSchedule(TEST_CLASS_NAME);
		Test.stopTest();
		jobs = [SELECT Id
		        FROM CronTrigger
		        WHERE CronJobDetail.Name = :(OC_AN_InternalAutomationScheduler.SCHEDULED_JOB_NAME_PRESET + TEST_CLASS_NAME)];
		System.assertEquals(0, jobs.size(), 'No schedule exsists');
	}

	@IsTest
	public static void scheduleCron(){
		TestScheduleClass testClass = new TestScheduleClass();

		Test.startTest();
		OC_AN_InternalAutomationScheduler.schedule(testClass, OC_AN_InternalAutomationScheduler.getCronString(200), TEST_CLASS_NAME);
		List<CronTrigger> jobs = [SELECT Id
		                          FROM CronTrigger
		                          WHERE CronJobDetail.Name = :(OC_AN_InternalAutomationScheduler.SCHEDULED_JOB_NAME_PRESET + TEST_CLASS_NAME)];
		System.assertEquals(1, jobs.size(), 'One schedule exsists');
		Test.stopTest();
		jobs = [SELECT Id
		        FROM CronTrigger
		        WHERE CronJobDetail.Name = :(OC_AN_InternalAutomationScheduler.SCHEDULED_JOB_NAME_PRESET + TEST_CLASS_NAME)];
		System.assertEquals(1, jobs.size(), 'One schedule exsists');
	}

	@IsTest
	public static void scheduleCronUsingFixedValue(){
		TestScheduleClass  testClass = new TestScheduleClass();
		Test.startTest();
		OC_AN_InternalAutomationScheduler.schedule(testClass, '0 15 1 ? * *', TEST_CLASS_NAME);
		List<CronTrigger> jobs = [SELECT Id
		                          FROM CronTrigger
		                          WHERE CronJobDetail.Name = :(OC_AN_InternalAutomationScheduler.SCHEDULED_JOB_NAME_PRESET + TEST_CLASS_NAME)];
		System.assertEquals(1, jobs.size(), 'One schedule exsists');
		Test.stopTest();
		jobs = [SELECT Id
		        FROM CronTrigger
		        WHERE CronJobDetail.Name = :(OC_AN_InternalAutomationScheduler.SCHEDULED_JOB_NAME_PRESET + TEST_CLASS_NAME)];
		System.assertEquals(1, jobs.size(), 'One schedule exsists');
	}

	@IsTest
	public static void getCronString(){
		Test.startTest();
		String cronString = OC_AN_InternalAutomationScheduler.getCronString(200);
		Test.stopTest();

		System.assert(!String.isEmpty(cronString), 'CronString cant be empty');
	}
}