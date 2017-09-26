/*
    Name        :    EinsteinManagerCtrl
    Author      :    Vishnu Kumar
    Description :    This class uses for Create, Delete and Train dataset. 
    
*/
public class EinsteinManagerCtrl{
    public string response{get;set;}
    public string modelName{get;set;}
    public string datasetName{get;set;}
    public string datasetUrl{get;set;}
    public string datasetid_ViewDetail{get;set;} 
    public string datasetId_TrainModel{get;set;} 
    public string modelId_RetrainModel{get;set;} 
    public string datasetId_AllModels{get;set;} 
    public string modelId_ViewModel{get;set;} 
    public string datasetId_DeleteDataset{get;set;} 
            
    public EinsteinManagerCtrl(){
        response = '';
        modelName = '';
        datasetName = '';
        datasetUrl = '';
        datasetid_ViewDetail = '';
        datasetId_TrainModel = '';
        modelId_RetrainModel = '';
        modelId_RetrainModel = '';
        datasetId_AllModels = '';
        modelId_ViewModel = '';
        datasetId_DeleteDataset = '';
    }
    
    //Create Dataset
    public void createDataset(){
        response = APIFactory.createVisionDataset(datasetName, datasetUrl , True);
    }
    
    //List Of All Dataset
    public void fetchAllDataset(){
        response = APIFactory.fetchListOfVisionDataset();
    }
    
    //Fetch Dataset Detail
    public void fetchDatasetDetail(){
        response = APIFactory.fetchVisionDataset(datasetid_ViewDetail);
    }
    
    //Train the Dataset
    public void trainDataset(){
        response = APIFactory.trainVisionDataset(datasetId_TrainModel , modelName );
    }
    
    //Retrain the Model
    public void reTrain(){
        response = APIFactory.reTrainVisionDataset(modelId_RetrainModel);
    }
    
    //View All Models
    public void fetchAllModels(){
        response = APIFactory.fetchVisionDatasetModels(datasetId_AllModels); 
    }
 
    //Fetch Model Detail or Training Status
    public void fetchModelDetail(){
        response = APIFactory.fetchVisionTrainingStatus('/'+modelId_ViewModel);
    }
    
    //Datset Delete
    public void doDeleteDataset(){
        response = APIFactory.deleteVisionDataset(datasetId_DeleteDataset);
    }
    
    
}