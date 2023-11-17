## Data migration workflow from mysql to ybdb

[Back to Workshop Home](../../README.md)

### Export schema and data from the source database

#### Step 0: Load data
Run only Step 0 from `mysql` shell
```
source ws/voyager/chinook.sql
```

Run Step 1 to Step 7 from `yb-voyager` shell
#### Step 1: Export Schema
```
yb-voyager export schema --export-dir ${GITPOD_REPO_ROOT}/${DATA_PATH} \
        --source-db-type ${SRC_DB_TYPE} \
        --source-db-host ${HOST} \
        --source-db-user ${SRC_USER} \
        --source-db-password ${SRC_SECRET} \
        --source-db-name ${SRC_DB_ID}
```

#### Step 2: Analyze Schema
```
yb-voyager analyze-schema --export-dir ${GITPOD_REPO_ROOT}/${DATA_PATH} --output-format html
```


#### Step 3: Export Data
```
yb-voyager export data --export-dir ${GITPOD_REPO_ROOT}/${DATA_PATH} \
        --source-db-type mysql \
        --source-db-host ${HOST} \
        --source-db-user ${SRC_USER} \
        --source-db-password ${SRC_SECRET} \
        --source-db-name ${SRC_DB_ID}
```

### Import schema and data into the target database

#### Step 4: Import Schema
```
yb-voyager import schema --export-dir ${GITPOD_REPO_ROOT}/${DATA_PATH} \
        --target-db-host ${HOST} \
        --target-db-user ${TARGET_USER} \
        --target-db-password ${TARGET_SECRET} \
        --target-db-name ${TARGET_DB_ID} \
        --target-db-schema ${SCHEMA}
```

#### Step 5: Import Data
```
yb-voyager import data --export-dir ${GITPOD_REPO_ROOT}/${DATA_PATH} \
        --target-db-host ${HOST} \
        --target-db-user ${TARGET_USER} \
        --target-db-password ${TARGET_SECRET} \
        --target-db-name ${TARGET_DB_ID} \
        --target-db-schema ${SCHEMA}
```

#### Step 6: Import indexes and triggers
```
yb-voyager import schema --export-dir ${GITPOD_REPO_ROOT}/${DATA_PATH} \
        --target-db-host ${HOST} \
        --target-db-user ${TARGET_USER} \
        --target-db-password ${TARGET_SECRET} \
        --target-db-name ${TARGET_DB_ID} \
        --target-db-schema ${SCHEMA} --post-import-data
```

### Step 7: Check the imported data status
```
yb-voyager import data status --export-dir ${GITPOD_REPO_ROOT}/${DATA_PATH}
```

[Back to Workshop Home](../../README.md)
