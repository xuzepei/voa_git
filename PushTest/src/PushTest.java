import javapns.back.PushNotificationManager;
import javapns.back.SSLConnectionHelper;
import javapns.data.Device;
import javapns.data.PayLoad;


public class PushTest {
//	private static final String PUSH_APPLE_HOST = "PUSH_APPLE_HOST";
//	private static final String PUSH_APPLE_PORT = "PUSH_APPLE_PORT";
//	private static final String PUSH_KEY_STORE_PATH = "PUSH_KEY_STORE_PATH";
//	private static final String PUSH_KEY_STORE_PASS = "PUSH_KEY_STORE_PASS";
//	private static PushNotificationManager pushManager = PushNotificationManager.getInstance();
//	public static void main(String[] args) {
//		PayLoad simplePayLoad = new PayLoad();
//		try {
//			String sn = "03ccc3b05f80e9b7fbfad84ee9f6b5e9ef86adec";
//			simplePayLoad.addBadge(1);
//
//			simplePayLoad.addAlert("test");
//			simplePayLoad.addSound("default");
//
//			String appleHost = SystemConfig.getProperty(PUSH_APPLE_HOST, "gateway.sandbox.push.apple.com");
//			int applePort = SystemConfig.getInt(PUSH_APPLE_PORT, 2195);
//			String keyStorePath = "D:/temp/apns-dev-cert.p12";
//			String keyStorePass = SystemConfig.getProperty(PUSH_KEY_STORE_PASS, "123456");
//			pushManager.initializeConnection(appleHost, applePort, keyStorePath, keyStorePass,
//					SSLConnectionHelper.KEYSTORE_TYPE_PKCS12);
//
//			Device client = pushManager.getDevice("782199bea7adcc5e31487fef6fede9e1541bdd926ec45eec881286046c85618a");
//			pushManager.sendNotification(client, simplePayLoad);
//
//			// removeDevice(deviceID);
//
//			pushManager.stopConnection();
//		} catch (Exception ex) {
//			ex.printStackTrace();
//		}
//	}
	
	
	// APNs Server Host & port
	//iPhoneId is iPhone's UDID (64-char device token)
	
	//开发版使用
	private static final String HOST = "gateway.sandbox.push.apple.com";
	private static String certificate = "./apns-dev-cert.p12";
	private static String iPhoneId = "74197de2e327baaa28599db049b7ad2fb012522b0302b25465396993567196e9";
	
	//正式版使用
//	private static final String HOST = "gateway.push.apple.com";
//	private static String certificate = "./apns-pro-cert.p12";
//	private static String iPhoneId = "3335664b4cc1d128606a4617b8b0c5e33f8c6330dc9440e8f54aba7387ef7a11";
//	

	private static final int PORT = 2195; 
	
	// Badge    
	private static final int BADGE = 1; 
	private static String passwd = "123456";
	public static void main(String[] args) throws Exception {
		
			System.out.println("Setting up Push notification");
			try { 
				
				// Setup up a simple message            
				PayLoad aPayload = new PayLoad();
				aPayload.addBadge(BADGE);
				aPayload.addSound("default");
				aPayload.addAlert("Test message from xzp.");
				System.out.println("Payload setup successfull.");
				System.out.println(aPayload); 
				
				// Get PushNotification Instance        
				PushNotificationManager pushManager = PushNotificationManager.getInstance();
				
				// Link iPhone's UDID (64-char device token) to a stringName          
				pushManager.addDevice("iPhone", iPhoneId);
				System.out.println("iPhone UDID taken.");
				System.out.println("Token: " + pushManager.getDevice("iPhone").getToken());
				
				// Get iPhone client        
				Device client = pushManager.getDevice("iPhone");
				System.out.println("Client setup successfull.");
				
				// Initialize connection         
				pushManager.initializeConnection(HOST, PORT, certificate, passwd, SSLConnectionHelper.KEYSTORE_TYPE_PKCS12);
				System.out.println("Connection initialized...");
				
				// Send message              
				pushManager.sendNotification(client, aPayload);
				System.out.println("Message sent!");
				System.out.println("# of attempts: " + pushManager.getRetryAttempts());
				pushManager.stopConnection();
				System.out.println("done");
			} catch (Exception e) {
				e.printStackTrace();
		}
		
	} 
}
