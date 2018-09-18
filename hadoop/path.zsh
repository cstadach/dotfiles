export HADOOP_PREFIX=/opt/hadoop
export HADOOP_HOME=/opt/hadoop
export SPARK_HOME=/opt/spark
export HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
export CDH_MR2_HOME=${HADOOP_HOME}
export HADOOP_USER_CLASSPATH_FIRST=true
export PATH=${HADOOP_HOME}/bin:${SPARK_HOME}/bin:$PATH
