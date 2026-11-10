// CalMG demo: monthly interest for a demo loan book. Bank policy: round half-up to 2 decimals.
public with sharing class CalMG_DemoEmiCalculator {
    // Interest for one month on a balance at an annual percentage rate.
    public static Decimal monthlyInterest(Decimal balance, Decimal annualRatePct) {
        return (balance * annualRatePct / 1200).setScale(2);
    }

    // Fixed principal repayment schedule: interest charged each month on the reducing balance.
    public static List<Decimal> schedule(Decimal principal, Decimal annualRatePct, Integer months) {
        List<Decimal> interest = new List<Decimal>();
        Decimal instalment = principal / months;
        Decimal remaining = principal;
        for (Integer m = 0; m < months; m++) {
            interest.add(monthlyInterest(remaining, annualRatePct));
            remaining -= instalment;
        }
        return interest;
    }
}