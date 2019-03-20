Public Class AgeRange
{
    Public Static String calculateAgeRange(Date age, string context)
    {
        String ageRange;
        Date yrs16 = date.newinstance((date.today().year() - 18), date.today().month(), date.today().day());
        Date yrs18 = date.newinstance((date.today().year() - 18), date.today().month(), date.today().day());
        Date yrs24 = date.newinstance((date.today().year() - 24), date.today().month(), date.today().day());
        Date yrs34 = date.newinstance((date.today().year() - 34), date.today().month(), date.today().day());
        Date yrs44 = date.newinstance((date.today().year() - 44), date.today().month(), date.today().day());
        Date yrs54 = date.newinstance((date.today().year() - 54), date.today().month(), date.today().day());
        Date yrs64 = date.newinstance((date.today().year() - 64), date.today().month(), date.today().day());
        if(context == 'Incident__c' && age > yrs16)
            ageRange = '<16';
        else if(context == 'Incident__c' && age <= yrs16 && age > yrs24)
            ageRange = '16-24';   
        else if(age > yrs18)
            ageRange = '<18';
        else if(age <= yrs18 && age > yrs24)
            ageRange = '18-24';
        else if(age <= yrs24 && age > yrs34)
            ageRange = '25-34';
        else if(age <= yrs34 && age > yrs44)
            ageRange = '35-44';
        else if(age <= yrs44 && age > yrs54)
            ageRange = '45-54';
        else if(age <= yrs54 && age > yrs64)
            ageRange = '55-64';
        else
            ageRange = '65+';
        return ageRange;
    }
}