/*
    Name        :    APIFactory
    Author      :    Vishnu Kumar
    Description :    This class contains all API functions for Einstein Vision. 
    
*/
public class APIFactory{
    //Einstein's platform service account's Email address
    public static String USER_EMAIL = 'vishnukumarramawat@gmail.com';
    
    //API List
    public static string API = 'https://api.einstein.ai/v1/';  
    public final static String VISION_DATASET = 'vision/datasets';
    public final static String VISION_TRAIN = 'vision/train';
    public final static String VISION_RETRAIN = 'vision/retrain';
    public final static String VISION_PREDICT = 'vision/predict';
    
    //Getting Access Token Start here
    public static String getAccessToken() {
        string tokenEndpoint = API+'oauth2/token';
        String access_token = null;
        
        String keyContents = '';
        
        
        if( !test.isRunningTest() ){
            list<ContentVersion> cvlist = [SELECT Title, VersionData FROM ContentVersion where Title='einstein_platform' OR  Title='predictive_services' ORDER BY Title LIMIT 1];
            
            if( cvlist.size() > 0 ){
                keyContents = cvlist[0].VersionData.tostring();
            }
        }

        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');
        
        // Get a new token
        JWT jwt = new JWT('RS256');
        // jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = keyContents; // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = USER_EMAIL;
        jwt.aud = tokenEndpoint;
        jwt.exp = '3600';
        
 
        String body = 'grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=' + jwt.issue();
        HttpRequest req = new HttpRequest();                            
        req.setMethod('POST');
        req.setEndpoint(tokenEndpoint);
        req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setBody(body);
        Http http = new Http();               
        HTTPResponse res = sendReq(req);
        
        if ( res.getStatusCode() == 200 ) {
            System.JSONParser parser = System.JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    parser.nextToken();
                    access_token = parser.getText();
                    break;
                }
            }
        }
        return access_token;   
    }
    //Getting Access Token End here
    
    //Predict Image Vision Part Start Here
    public static string predictImage(String sample, String model, boolean isBase64) {
        String access_token = getAccessToken();
        string contentType = HttpFormBuilder.GetContentType();
        //  Compose the form
        string form64 = '';

        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('modelId', EncodingUtil.urlEncode(model, 'UTF-8'));
        form64 += HttpFormBuilder.WriteBoundary();
        
        if(isBase64) {
            form64 += HttpFormBuilder.WriteBodyParameter('sampleBase64Content', sample);
        }
        else {
            form64 += HttpFormBuilder.WriteBodyParameter('sampleLocation', sample);
        }
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);

        blob formBlob = EncodingUtil.base64Decode(form64);
 
        return generalPostCall( VISION_PREDICT , formBlob).getBody();
    }
    //Predict Image Vision Part End Here
    
    //1 - Fetch all Datasets
    public static string fetchListOfVisionDataset(){
        return generalGetCall(VISION_DATASET).getBody();
    }

    //2 - Create Dataset
    public static string createVisionDataset(string DSname, string pathURL, boolean isSynchronously ){
        String body = '';
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('name', DSname);
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('path', pathURL);
        body += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
        Blob bodyBlob = EncodingUtil.base64Decode(body);
        
        string API_URL= APIFactory.VISION_DATASET+'/upload';
        if( isSynchronously ){
            API_URL += '/sync';
        }
        
        return generalPostCall( API_URL , bodyBlob).getBody();
    }
    
    //3 - Fetch Detail of Dataset
    public static string fetchVisionDataset(string did){
        return generalGetCall(VISION_DATASET+'/'+did).getBody();
    }
    
    //4 - Delete Dataset
    public static string deleteVisionDataset(string did){
        return generalDeleteCall(VISION_DATASET+'/'+did).getBody();
    }
    
    //5 - Fetch All Models of Dataset
    public static string fetchVisionDatasetModels(string params){
        return generalGetCall(VISION_DATASET +'/'+params+'/models').getBody();
    }
    
    //6 - Train the Dataset
    public static string trainVisionDataset(string dsId, string modelName ){
        String body = '';
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('name', modelName);
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('datasetId', dsId );
        body += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
        Blob bodyBlob = EncodingUtil.base64Decode(body);

        return generalPostCall(VISION_TRAIN, bodyBlob).getBody();
    }
    
    //7 - Fetch Training Status
    public static string fetchVisionTrainingStatus(string params){
        return generalGetCall(VISION_TRAIN+params).getBody();
    }
    
    //8 - Retrain the Model
    public static string reTrainVisionDataset(string modelid ){
        String body = '';
        body += HttpFormBuilder.WriteBoundary();
        body += HttpFormBuilder.WriteBodyParameter('modelId', modelId );
        body += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);
        Blob bodyBlob = EncodingUtil.base64Decode(body);

        return generalPostCall(VISION_RETRAIN, bodyBlob).getBody();
    }
    
    /**************GENERAL POST, GET and DELETE CALL METHODS****************/
    //General Method for Post Call
    public static HTTPResponse generalPostCall(string endPoint , blob body ) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader('Authorization', 'Bearer ' + getAccessToken());
        httpRequest.setHeader('Content-Type',  HttpFormBuilder.GetContentType() );
        httpRequest.setHeader('Cache-Control', 'no-cache');
        httpRequest.setMethod('POST'); 
        httpRequest.setBodyAsblob(body);
        httpRequest.setEndpoint(API+endPoint);
 
        Http http = new Http();
        
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info,httpRequest.getEndpoint() ) );
        return sendReq(httpRequest);
    }
    
    //General Method for Get Call
    public static HTTPResponse generalGetCall(string endPoint ) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader('Authorization','Bearer ' + getAccessToken() );
        httpRequest.setHeader('Content-Type', HttpFormBuilder.GetContentType() );
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setMethod('GET');
        httpRequest.setTimeout(120000);
        httpRequest.setEndpoint(API+endPoint);

        Http http = new Http();
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info,httpRequest.getEndpoint() ) );
        return sendReq(httpRequest);
    }
    
    //General Method for Delete Call
    public static HTTPResponse generalDeleteCall(string endPoint ) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setHeader('Authorization','Bearer ' + getAccessToken() );
        httpRequest.setHeader('Content-Type', HttpFormBuilder.GetContentType() );
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setMethod('DELETE');
        httpRequest.setTimeout(120000);
        httpRequest.setEndpoint(API+endPoint);

        
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.Info,httpRequest.getEndpoint() ) );
        return sendReq(httpRequest);
    }
    
    //General Method for Make HTTP request
    public static HTTPResponse sendReq(HttpRequest httpRequest){
        Http http = new Http();
        HTTPResponse httpResp = new HTTPResponse();
        if( !test.isRunningTest() ){
            httpResp = http.send(httpRequest);
        }
        else{
            httpResp.setBody('');
            httpResp.setStatusCode(200);
        }
        return httpResp;
    }
}