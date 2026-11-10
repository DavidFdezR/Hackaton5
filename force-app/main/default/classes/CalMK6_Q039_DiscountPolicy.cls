/** Q-039 untouched neighbour (state after the reviewer reverted the agent's drive-by change): Gold = 10%. */
public with sharing class CalMK6_Q039_DiscountPolicy {
    public static Decimal pctFor(String tier) {
        return tier == 'Gold' ? 10 : 0;
    }
}