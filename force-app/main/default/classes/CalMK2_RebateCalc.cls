/**
 * CALHACK Friday (CalMK2_) demo. Deliberately under-tested: CalMK2_RebateCalcTest covers only tierFor().
 */
public with sharing class CalMK2_RebateCalc {
    public static String tierFor(Decimal amount) {
        if (amount == null) {
            return 'NONE';
        }
        if (amount >= 100000) {
            return 'GOLD';
        }
        if (amount >= 10000) {
            return 'SILVER';
        }
        return 'BRONZE';
    }

    public static Decimal rebateFor(Decimal amount, String region) {
        Decimal rate = 0;
        String tier = tierFor(amount);
        if (tier == 'GOLD') {
            rate = 0.05;
        } else if (tier == 'SILVER') {
            rate = 0.03;
        } else if (tier == 'BRONZE') {
            rate = 0.01;
        }
        if (region == 'EMEA') {
            rate = rate + 0.005;
        } else if (region == 'APAC') {
            rate = rate + 0.0025;
        }
        Decimal rebate = amount * rate;
        if (rebate > 25000) {
            rebate = 25000;
        }
        return rebate.setScale(2);
    }

    public static List<Decimal> rebatesFor(List<CalMK2_Invoice__c> invoices, String region) {
        List<Decimal> out = new List<Decimal>();
        for (CalMK2_Invoice__c inv : invoices) {
            out.add(rebateFor(inv.Amount__c, region));
        }
        return out;
    }
}