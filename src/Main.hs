module Main where

import Control.Monad.IO.Class
import Control.Monad.Logger
import Database.Esqueleto
import Database.Persist
import Database.Persist.Postgresql
import Database.Persist.TH

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Number
   value Int
|]

connStr = "host=localhost dbname=test user=test password=test port=5432"

main :: IO ()
main = runStderrLoggingT $ withPostgresqlPool connStr 10 $ \pool -> liftIO $ do
    flip runSqlPersistMPool pool $ do
        runMigration migrateAll

        johnId <- insert $ Number 5
        janeId <- insert $ Number 22
        return ()
        _ :: [Value (Maybe Int)] <- select $
          from $ \number -> do
            return $ sum_ $ number ^. NumberValue
        return ()

