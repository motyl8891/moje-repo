public without sharing class TradeComplianceHelper {

	/**
	 * Risk levels
	 */
	private static final String highRisk = 'High';
	private static final String mediumRisk = 'Medium';
	private static final String lowRisk = 'Low';

	/**
	 * Method that updates  Opportunity Sales Compliance Risk value based on country risk level
	 * @param newOpportunities    Opportunitys what were changed
	 * @param oldOpportunitiesMap Opportunity before it was changed
	 */
	public static void updateCountryRiskOpptys(List<Opportunity> newOpportunities, Map<ID, Opportunity> oldOpportunitiesMap) {
        Try{
		List<Opportunity> opptyList = new List<Opportunity>();
		for (Opportunity newOppty : newOpportunities) {
			Opportunity oldOppty = oldOpportunitiesMap.get(newOppty.Id);
			if (newOppty.Ship_To_Countries__c != null &&
			        (oldOppty==null || newOppty.Ship_To_Countries__c != oldOppty.Ship_To_Countries__c)) {
				opptyList.add(newOppty);
			}
		}
		if (opptyList.size() != 0) {
			setSalesComplianceRisk(opptyList);
		}
            }catch(Exception e){	}
	}

	/**
	 * Method that sets Opportunity Sales Compliance Risk value based on country risk level
	 * @param opptyList Opportunity list
	 */
	private static void setSalesComplianceRisk(List<Opportunity> opptyList) {
        Try{
		Set<String> uniqueCountries = getUniqueCountries(opptyList);
		Map<String, String> countryRiskMap = getCountryRiskMap(uniqueCountries);
		Boolean isHigh = false;
		Boolean isMedium = false;
		Boolean isLow = false;
		String shortCountry;
		for (Opportunity oppty : opptyList) {
			List<String> countries = oppty.Ship_To_Countries__c.split(';');
			for (String country : countries) {
                country =country.trim();
				for (String countryRisk : countryRiskMap.keySet()) {
					if (country.length() != countryRisk.length() && country.length() > countryRisk.length()) {
						shortCountry = country.substring(0, countryRisk.length());
					} else {
						shortCountry = country;
					}
					if (shortCountry == countryRisk) {
						if (countryRiskMap.get(shortCountry) == highRisk) {
							isHigh = true;
						} else if (countryRiskMap.get(shortCountry) == mediumRisk) {
							isMedium = true;
						} else {
							isLow = true;
						}
					}
				}
			}
			setSalesComplianceCountryRisk(oppty, isHigh, isMedium, isLow);
			isHigh = false;
			isMedium = false;
			isLow = false;
		}
            }catch(Exception e){	}
	}

	/**
	 * Method that finds all Custom Setting Country Risk records based on country Name
	 * @param  uniqueCountries Set containing Country names
	 * @return                 Map with key country and object Country Risk
	 */
	private static Map<String, String> getCountryRiskMap(Set<String> uniqueCountries) {
		Set<String> tempCountries = new Set<String>();
		String tmp;
		for (String uc : uniqueCountries) {
			if (uc.length() > 15) {
				tmp = uc.substring(0, 15) + '%';
			} else {
				tmp = uc + '%';
			}
			tempCountries.add(tmp.trim()); 
		}

		Map<String, String> countryRiskMap = new Map<String, String>();
        //NS
        Try{
        for (Country_Risk__c country : [SELECT Name, Risk__c
                                        FROM Country_Risk__c
                                        WHERE Name LIKE : tempCountries
                                       Limit : (Limits.getLimitQueryRows()-Limits.getQueryRows())]) {
			countryRiskMap.put(country.Name, country.Risk__c);
		}
            }catch(Exception e){	}
		return countryRiskMap;
	}

	/**
	 * Method that gets all the country names from Ship To Country field without duplicate values
	 * @param  opptyList List of Opportunitys
	 * @return           Set containing unique country names
	 */
	private static Set<String> getUniqueCountries(List<Opportunity> opptyList) {
		Set<String> uniqueCountries = new Set<String>();
        Try{
		for (Opportunity oppty : opptyList) {
			List<String> countries = oppty.Ship_To_Countries__c.split(';');
			for (String country : countries) {
				if (!uniqueCountries.contains(country)) {
					uniqueCountries.add(country);
				}
			}
		}
            }catch(Exception e){	}
		return uniqueCountries;
	}

	/**
	 * Method that depending on which risk level is true sets Opportunity Sales Compliance Country Risk value
	 * @param oppty    Opportunity Object
	 * @param isHigh   High risk state
	 * @param isMedium Medium risk state
	 * @param isLow    Low risk state
	 */
	private static void setSalesComplianceCountryRisk(Opportunity oppty, Boolean isHigh, Boolean isMedium, Boolean isLow) {
        Try{	
		if (isHigh == true) {
			oppty.Sales_Compliance_Country_Risk__c = highRisk;
		} else if (isMedium == true && isHigh == false) {
			oppty.Sales_Compliance_Country_Risk__c = mediumRisk;
		} else if (isMedium == false && isHigh == false && isLow == true) {
			oppty.Sales_Compliance_Country_Risk__c = lowRisk;
		}
            }catch(Exception e){	}
	}
        
}