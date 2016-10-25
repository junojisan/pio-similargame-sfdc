/**
 * PredictionIOデモアプリ
 * Enginが返すRecommend情報を保持するDTOクラスです
 * @author junji.imaoka
 */
public with sharing class RecommendItemScoreDto {
	public ItemScore[] itemScores {get; set;}
	public static RecommendItemScoreDto parse(String json){
		return (RecommendItemScoreDto)System.JSON.deserialize(json, RecommendItemScoreDto.class);
	}
	public class ItemScore{
		public String item {get; set;}
		public Double score {get; set;}
	}
}
