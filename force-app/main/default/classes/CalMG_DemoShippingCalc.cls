// CALHACK-103 X-04 first attempt: Integer arithmetic throughout.
public with sharing class CalMG_DemoShippingCalc {
    public static Integer boxesNeeded(Integer units, Integer perBox) {
        return units / perBox;
    }

    public static Integer discountPercent(Integer discount, Integer listPrice) {
        return discount * 100 / listPrice;
    }
}