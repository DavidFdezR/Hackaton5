/** CALHACK round3 B (T-171 Federation ID, T-172 freeze, RESERVE-1 email change). User administration actions, all on test-created users (rolled back). */
@IsTest
private class CalMK4F_UserAdminTest {
    /** RESERVE-1: an admin email change on another user takes effect at once; password resets then go to the new inbox. */
    @IsTest static void reserve1_emailChangeIsImmediate() {
        User u;
        System.runAs(CalMK4F_TestUsers.me()) {
            u = CalMK4F_TestUsers.make('approver');
            String old = [SELECT Email FROM User WHERE Id = :u.Id].Email;
            u.Email = 'new.inbox@calmk4f-requester.example';
            update u;
            User r = [SELECT Email, Username, IsActive FROM User WHERE Id = :u.Id];
            CalMK4F_TestUsers.ev('RESERVE-1 email before=' + old + ' after update=' + r.Email + ' (no pending state; username unchanged ends with ' + r.Username.substringAfter('@') + ')');
            System.assertEquals('new.inbox@calmk4f-requester.example', r.Email);
        }
    }

    /** T-172: freezing blocks login but keeps the user active, its licence and the records it owns. */
    @IsTest static void t172_freezeKeepsUserActiveAndOwnership() {
        User u;
        System.runAs(CalMK4F_TestUsers.me()) { u = CalMK4F_TestUsers.make('frozen'); CalMK4F_TestUsers.grant(u.Id, 'CalMK4F_DemoHR_PS'); }
        CalMK4F_DemoEmployee__c e;
        System.runAs(u) { e = new CalMK4F_DemoEmployee__c(Name = 'CalMK4F Demo Employee Owned'); insert e; }
        System.runAs(CalMK4F_TestUsers.me()) {
            UserLogin ul = [SELECT Id, IsFrozen FROM UserLogin WHERE UserId = :u.Id];
            Boolean was = ul.IsFrozen;
            ul.IsFrozen = true; update ul;
            User r = [SELECT IsActive FROM User WHERE Id = :u.Id];
            Id owner = [SELECT OwnerId FROM CalMK4F_DemoEmployee__c WHERE Id = :e.Id].OwnerId;
            Integer psa = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :u.Id AND PermissionSet.Name = 'CalMK4F_DemoHR_PS'];
            ul.IsFrozen = false; update ul;
            Boolean unfrozen = [SELECT IsFrozen FROM UserLogin WHERE Id = :ul.Id].IsFrozen;
            CalMK4F_TestUsers.ev('T-172 IsFrozen ' + was + '->true; IsActive=' + r.IsActive + '; owned record still owned by user=' + (owner == u.Id)
                + '; HR permission set still assigned=' + (psa == 1) + '; unfreeze -> IsFrozen=' + unfrozen);
            System.assert(r.IsActive && owner == u.Id && psa == 1 && !unfrozen);
        }
    }

    /** T-171: Federation ID is unique per org and an admin can repoint it with no verification. */
    @IsTest static void t171_federationIdRepoint() {
        System.runAs(CalMK4F_TestUsers.me()) {
            User a = CalMK4F_TestUsers.make('fedA');
            User b = CalMK4F_TestUsers.make('fedB');
            a.FederationIdentifier = 'calmk4f.approver@idp.example'; update a;
            String dup;
            try { b.FederationIdentifier = 'calmk4f.approver@idp.example'; update b; dup = 'allowed'; }
            catch (Exception ex) { dup = ex.getMessage().substringAfter('FIELD_INTEGRITY_EXCEPTION, ').left(60); }
            a.FederationIdentifier = 'calmk4f.requester@idp.example'; update a;
            CalMK4F_TestUsers.ev('T-171 fed id repointed to ' + [SELECT FederationIdentifier FROM User WHERE Id = :a.Id].FederationIdentifier + ' immediately; duplicate on second user: ' + dup);
            System.assertEquals('calmk4f.requester@idp.example', [SELECT FederationIdentifier FROM User WHERE Id = :a.Id].FederationIdentifier);
        }
    }
}