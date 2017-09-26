/*
    Name        :    iPredictCtrl
    Author      :    Vishnu Kumar
    Description :    This class uses for vision prediction. 
    
*/
public class iPredictCtrl{
    private string MODELID = '6Z3NFQHWL7HATG524CGLSMXIUQ';
    
    public Attachment atcObj{get;set;}
    public string url{get;set;}
    public string base64String{get;set;}
    public list<SelectOption> searchTypeSelOpt{get;set;}
    public string selSearchOpt{get;set;}
    public string response{get;set;}
    
    public iPredictCtrl(){
        atcObj = new Attachment();
        selSearchOpt = 'url';
        response = '';
        
        searchTypeSelOpt = new list<SelectOption>();
        searchTypeSelOpt.add( new SelectOption('url', 'URL') );
        searchTypeSelOpt.add( new SelectOption('image', 'Image') );
        searchTypeSelOpt.add( new SelectOption('base64', 'Base64') );
    }
    
    public void doSearch(){
        if( selSearchOpt == 'url' ) {
            predictUrl();
        }
        else if( selSearchOpt == 'image' ){
            predictBlob();
        }
        else if( selSearchOpt == 'base64' ){
            predictBase64();
        }
        
        
        atcObj = new Attachment();
        base64String = '';
        url = '';
    }
    
    private void predictUrl() {
        response = APIFactory.predictImage(url, MODELID, false);
    }

    public void predictBlob() {
        response = APIFactory.predictImage(EncodingUtil.base64Encode(atcObj.body),  MODELID, true);
    }
    
    public void predictBase64() {
        response = APIFactory.predictImage(base64String,  MODELID, true);
    }
}