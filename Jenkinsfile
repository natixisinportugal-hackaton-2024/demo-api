pipeline {
    agent {
        docker {
            image 'tools/maven3/apache-maven-3.8.4-jdk-21.0.2:1.0'
            label 'slave-generic-ocp-2'
        }
    }

    environment {
        //Openshift Namespace
        OCP_PROJECT_NAME = "jgu-usrmgmt-dev-nat"
        //Openshift build configuration
        OCP_BUILD_CONFIG_NAME = "api-mocked-buildconfig"
        //Application name
        APP_IMAGE_NAME = "api-mocked"
        //Name of the image to create (Format : ArtifactoryUrl/Image:Tag)
        ART_IMAGE_NAME = "jgu-docker-openshift.artifactory.mycloud.intranatixis.com/${APP_IMAGE_NAME}:${RELEASE_ID}"
        //Name of the pull secret used to download base image from Artifactory
        OCP_PULL_SECRET = "openshiftNXJGUbuild_token"
        //Name of the push secret used to push created image to Artifactory
        OCP_PUSH_SECRET = "openshiftNXJGUbuild_token"
        //Number of CPU max for the build
        BUILD_MAX_CPU = "0.2"
        //Memory limit for the build
        BUILD_MAX_MEMORY = "0.4Gi"
        OCP_BUILD_TOKEN_NAME = "cicdsa-token-dev"

        APP_CONFIGURATION_DPL = "deployment.yml"
        APP_CONFIGURATION_XLD = "deploy.xml"
        APP_CONFIGURATION_CONFIG_MAP = "configMap.yml"
        APP_CONFIGURATION_SRV = "service.yml"
        APP_CONFIGURATION_ROUTE = "route.yml"

        APP_OPENSHIFT_NAME = "api-mocked"

        //APP_XLD_ENVIRONMENT = "${APP_OPENSHIFT_NAME}.env"
        APP_S2I_CONFIGURATION_FOLDER = "configuration"
        APP_S2I_ENVIRONMENT_FOLDER = ".s2i"
        APP_S2I_ENVIRONMENT_FILE = "environment"
        APP_MANIFEST_PATH = "${APP_S2I_CONFIGURATION_FOLDER}/${APP_CONFIGURATION_XLD}"

    }

    parameters {
        string defaultValue: "0.0.1", description: "Version of the application", name: "RELEASE_ID", trim: true
    }


    stages {

        stage('Maven Install ') {
            steps {
				sh "mvn clean install -P xld -DskipTests -DprojectVersion=$RELEASE_ID"

            }
        }

        stage('Openshift prepare build') {
            steps {

                script {
                    //Select the Openshift cluster (defined in the global configuration)
                    openshift.withCluster("insecure://api.ocp-retail-hpr-1.mycaas.intrabpce.fr:6443") {
                        //Select the Openshift Token (Defined as credential at the Folder level)
                        openshift.withCredentials("${OCP_BUILD_TOKEN_NAME}") {
                            //Select the build Namespace
                            openshift.withProject("${OCP_PROJECT_NAME}") {

                                //Check if the Build configuration already exists
                                def bc = openshift.selector("bc", "${OCP_BUILD_CONFIG_NAME}");
                                if (bc.exists()) {
                                    //RemRuove an existing build configuration
                                    echo "Removing existing Build configuration (${OCP_BUILD_CONFIG_NAME})..."
                                    openshift.delete("bc ${OCP_BUILD_CONFIG_NAME}")
                                    echo "${OCP_BUILD_CONFIG_NAME} Build configuration removed successfully"
                                }

                                echo "Creating Build configuration (${OCP_BUILD_CONFIG_NAME})..."
                                //Create now the Build configuration
                                bc = openshift.newBuild("--name=${OCP_BUILD_CONFIG_NAME}",         \
                                                        "--allow-missing-images=true",         \
                                                        "--to=${ART_IMAGE_NAME}",         \
                                                        "--to-docker=true",         \
                                                        "--context-dir=/event-api",         \
                                                        "--strategy=docker",         \
                                                        "--binary=true",         \
                                                        "--build-secret=${OCP_PULL_SECRET}",         \
                                                        "--push-secret=${OCP_PUSH_SECRET}")
                                echo "${OCP_BUILD_CONFIG_NAME} Build configuration created successfully"

                                //Updating Build configuration with memory and cpu limits
                                echo "Updating ${OCP_BUILD_CONFIG_NAME} Build configuration with CPU (${BUILD_MAX_CPU})/Memory (${BUILD_MAX_MEMORY}) limits..."
                                openshift.patch("bc/${OCP_BUILD_CONFIG_NAME}", "\'{\"spec\":{\"resources\":{\"limits\":{\"memory\":\"${BUILD_MAX_MEMORY}\", \"cpu\":${BUILD_MAX_CPU}}}}}\'")
                                echo "${OCP_BUILD_CONFIG_NAME} Build configuration updated successfully"

                            }//End withProject
                        }//End withCredentials
                    }// End withCluster
                }//End Script
            }//End steps
        }//End stage


        stage('Openshift run build') {
            steps {

                script {
                    //Select the Openshift cluster (defined in the global configuration)
                    openshift.withCluster("insecure://api.mycaas-np-2.intranatixis.com:6443") {
                        //Select the Openshift Token (Defined as credential at the Folder level)
                        openshift.withCredentials("${OCP_BUILD_TOKEN_NAME}") {
                            //Select the build Namespace
                            openshift.withProject("${OCP_PROJECT_NAME}") {

                                echo "Running Openshift build..."
                                //Check if the Build configuration already exists
                                def bc = openshift.selector("bc", "${OCP_BUILD_CONFIG_NAME}");
                                bc.startBuild("--from-dir=rpg-backend/rpg-api", "--wait", "--follow");
                                echo "Openshift build finished successfully"


                            }//End withProject
                        }//End withCredentials
                    }//End withCluster

                }//End script
            }//End steps
        }//End stage

/*        stage('Publish XLDeploy Package') {
            steps {
                echo "Creating XL Deploy package..."
                xldCreatePackage artifactsPath: '', darPath: 'event-api-${RELEASE_ID}.dar', manifestPath: 'rpg-backend/rpg-api/configuration/deploy.xml'
                echo "XL Deploy package created successfully"

                echo "Publising XL Deploy package..."
                xldPublishPackage darPath: 'event-api-${RELEASE_ID}.dar', serverCredentials: 'xldeploy-phr'
                echo "XL Deploy package published successfully..."
            }//End steps
        }//End stage
*/

    }//End stages

}//End pipeline
