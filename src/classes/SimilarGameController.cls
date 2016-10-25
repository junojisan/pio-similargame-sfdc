/**
 * PredictionIOデモアプリ
 * ゲームのお勧めを行います
 * @author junji.imaoka
 */
public with sharing class SimilarGameController {

	private static final String END_POINT = 'http://pio-engine-jimaoka.herokuapp.com/queries.json';
	private static final Integer NUMBER_OF_RECOMMENDATION = 4;

	public Favorite__c favorite {get; set;}
	private ApexPages.StandardController stdController;

	public String request {get; set;}
	public String response {get; set;}
	public List<SimilarGameDto> similarGameDtos {get; set;}

	/**
	 * コンストラクタ
	 * @param stdController
	 * @return SimilarGameController
	 */
    public SimilarGameController(ApexPages.StandardController stdController) {
        this.favorite = (Favorite__c)stdController.getRecord();
		this.favorite = [Select Id, Name, Game__c, GameNumber__c, Customer__c, CustomerNumber__c, Image__c, Genre__c From Favorite__c Where Id = :this.favorite.Id];
		this.stdController = stdController;
    }

	/**
	 * Cancelボタンのハンドラです
	 * @param
	 * @return PageReference
	 */
	public PageReference doCancel(){
		return stdController.cancel();
	}

	/**
	 * Recommendボタンのハンドラです
	 * @param
	 * @return PageReference
	 */
	public PageReference doRecommend(){
		createDto(getRecommend());
		return null;
	}

	/**
	 * EnginからRecommendを取得します
	 * @param
	 * @return RecommendItemScoreDto
	 */
	private RecommendItemScoreDto getRecommend(){
		JSONGenerator generator = JSON.createGenerator(true);
		generator.writeStartObject();
		generator.writeFieldName('items');
		generator.writeStartArray();
		generator.writeString(favorite.GameNumber__c);
		generator.writeEndArray();
		generator.writeNumberField('num', NUMBER_OF_RECOMMENDATION);
		generator.writeEndObject();
		request = generator.getAsString();

		HttpRequest req = new HttpRequest();
		req.setHeader('Content-type', 'application/json');
		req.setMethod('GET');
		req.setEndPoint(END_POINT);
		req.setBody(request);
		req.setTimeout(60000);

		RecommendItemScoreDto itemScoreDto = null;
		try{
			Http http = new Http();
			HttpResponse res = http.send(req);
			response = res.getBody();
			itemScoreDto = RecommendItemScoreDto.parse(response);
		}catch(Exception e){
			System.debug(LoggingLevel.ERROR, e);
		}
		return itemScoreDto;
	}

	/**
	 * 画面表示用のDTOを生成します
	 * @param
	 * @return
	 */
	private void createDto(RecommendItemScoreDto itemScoreDto){
		similarGameDtos = new List<SimilarGameDto>();

		Map<String, SimilarGameDto> similarGameMap = new Map<String, SimilarGameDto>();
		for(RecommendItemScoreDto.ItemScore itemScore : itemScoreDto.itemScores){
			SimilarGameDto similarGameDto = new SimilarGameDto();
			similarGameDto.gameNumber = itemScore.item;
			similarGameDto.score = itemScore.score;
			similarGameMap.put(similarGameDto.gameNumber, similarGameDto);
			similarGameDtos.add(similarGameDto);
		}

		for(Game__c game : [Select Name, GameNumber__c, Genre__c, ImageURL__c From Game__c Where GameNumber__c In : similarGameMap.keySet()]){
			SimilarGameDto similarGameDto = similarGameMap.get(game.GameNUmber__c);
			similarGameDto.game = game.Name;
			similarGameDto.genre = game.Genre__c;
			similarGameDto.image = game.ImageURL__c;
		}
	}

	/**
	 * Recommend情報インナークラス
	 */
	public class SimilarGameDto{
		public String game {get; set;}
		public String gameNumber {get; set;}
		public String image {get; set;}
		public String genre {get; set;}
		public Double score {get; set;}
	}
}
