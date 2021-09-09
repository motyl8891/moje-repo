public class CRGApprovers {
	public String CRGAccountPrimaryKAM {
		get {
			return CRGAccountPrimaryKAM;
		}
		set;
	}

	public String CRGAccountCUHead {
		get {
			return CRGAccountCUHead;
		}
		set;
	}

	public CRGApprovers(String CRGAccountPrimaryKAM, String CRGAccountCUHead) {
		this.CRGAccountPrimaryKAM = CRGAccountPrimaryKAM;
		this.CRGAccountCUHead = CRGAccountCUHead;
	}
}