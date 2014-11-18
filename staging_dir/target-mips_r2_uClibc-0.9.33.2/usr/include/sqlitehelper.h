#ifndef SQLITEHELPER_H
#define SQLITEHELPER_H

#include <sqlite3.h>
#include <string>
#include "threadmutex.h"

using namespace std;

#ifndef SQLITE_COMMAND_LENGTH_MAX
#define SQLITE_COMMAND_LENGTH_MAX   256
#endif

class SqliteCommandListener
{
public:
    SqliteCommandListener(){}
    virtual ~SqliteCommandListener(){}

public:
    virtual int SqliteCallbackDispatcher(int cmdId, int n_column, char ** column_value, char ** column_name) = 0;
};

class SqliteHelper
{
public:
    static SqliteHelper* GetInstance();
    static void DestroyInstance();
    ~SqliteHelper();

    int open_database(const char* strDatabasePath);
    int close_database();
    int execute_command(int cmdId, SqliteCommandListener *listener, const char * strCmd, char* &pErrMsg);
//    int execute_command_no_cb(char * strCmd, char ***resulttp, int *nrow, int *ncolumnm, char *pErrMsg);
//    void free_table(char **resulttp);

    void lock_database();
    void unlock_database();

    friend int Sqlite_Callback(void *param, int n_columm, char **column_value, char **column_name);

private:
    SqliteHelper();
    int recover_database(const char* strDatabasePath);
    int check_database(const char* strDatabasePath);
    int check_tables();
private:
    int m_cmdId;
    sqlite3 *m_database;
    SqliteCommandListener   *m_listener;
    CThreadMutex m_mutex;
    static SqliteHelper *m_instance;
};

#endif // SQLITEHELPER_H
