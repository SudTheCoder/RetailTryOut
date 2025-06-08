public class ASDAC_SFMCEmailCallout {
    
    
    public static String generateString(Integer intStringLength) {
        final String strChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
        String strNull = '';
        while (strNull.length() < intStringLength) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), strChar.length());
            strNull += strChar.substring(idx, idx+1);
        }
        return strNull; 
    }

}