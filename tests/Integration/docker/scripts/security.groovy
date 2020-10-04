#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.security.s2m.AdminWhitelistRule
import hudson.security.csrf.DefaultCrumbIssuer
import jenkins.model.Jenkins

def instance = Jenkins.getInstance()

/*
    Configure the admin user with a known password
*/
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "admin")
instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)
instance.save()

Jenkins.instance.getInjector().getInstance(AdminWhitelistRule.class).setMasterKillSwitch(false)

/*
    Ensure CSRF is enabled on the master
*/
if(!Jenkins.instance.isQuietingDown()) {
    def j = Jenkins.instance
    if(j.getCrumbIssuer() == null) {
        j.setCrumbIssuer(new DefaultCrumbIssuer(true))
        j.save()
        println 'CSRF Protection configuration has changed.  Enabled CSRF Protection.'
    }
    else {
        println 'Nothing changed.  CSRF Protection already configured.'
    }
}
else {
    println "Shutdown mode enabled.  Configure CSRF protection SKIPPED."
}
