#!/usr/bin/env groovy
import hudson.model.JDK
import hudson.tools.InstallSourceProperty
import io.jenkins.plugins.adoptopenjdk.AdoptOpenJDKInstaller
import jenkins.model.Jenkins

Jenkins.instance.setNumExecutors(10)

final versions = [
        'jdk14': 'jdk-14.0.2+12'
]

Jenkins.instance.getDescriptor(hudson.model.JDK).with {
    installations = versions.collect {
        new JDK(it.key, '', [
                new InstallSourceProperty([
                        new AdoptOpenJDKInstaller(it.value)
                ])
        ])
    } as JDK[]

}
