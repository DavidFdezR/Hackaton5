// CALHACK-103 X-08 first attempt: due date = calendar day of createdAt (taken in GMT) + 30 days.
public with sharing class CalMG_DemoDueDateService {
    public static Date dueDate(Datetime createdAt) {
        return createdAt.dateGmt().addDays(30);
    }
}