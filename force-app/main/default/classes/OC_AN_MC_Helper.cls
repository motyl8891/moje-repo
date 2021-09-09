public class OC_AN_MC_Helper {
	public class AssetType { String name;
		public Integer id;
	}

	public class Views {
		public Html html;
		public Text text;
		public Text subjectline;
		public Text preheader;
	}

	public String name;
	public Channels channels;
	public Views views;
	public AssetType assetType;

	public class Html {
		public String content;
	}

	public class Text {
	}

	public class Channels {
		public Boolean email;
		public Boolean web;
	}

	
	public static OC_AN_MC_Helper parse(String json) {
		return (OC_AN_MC_Helper) System.JSON.deserialize(json, OC_AN_MC_Helper.class);
	}
}