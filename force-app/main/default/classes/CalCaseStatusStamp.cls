public with sharing class CalCaseStatusStamp {
    public static Integer runs = 0;

    public static void afterSave(List<Case> cases) {
        runs++;
        List<Case> stamps = new List<Case>();
        for (Case c : cases) {
            stamps.add(new Case(Id = c.Id, Description = 'Status: ' + c.Status));
        }
        update stamps;
    }
}