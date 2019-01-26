
{-# LANGUAGE OverloadedStrings #-}
-- pentru a construi cu valori de tip text

module Main where

import           Control.Monad          (forM_)
import           Control.Monad.IO.Class (liftIO)
import           Data.IORef
import           Data.Semigroup         ((<>))
-- import           Data.Text              (Text)
import qualified Data.Text              as T
-- import           Data.Time.Calendar
-- import           Data.Time.Clock
import           Database.SQLite.Simple
import           Lucid
import           Web.Spock
import           Web.Spock.Config
import           Web.Spock.Lucid        (lucid)

newId::(Int)->Int
newId (i)=i+1

-- definiția obiectului event
data Event = Event {i:: Int, date::T.Text, content::T.Text, hour::T.Text} deriving (Show)

-- mapare atribute cu baza de date
instance FromRow Event where
  fromRow = Event <$> field <*> field <*> field <*> field

instance ToRow Event where
  toRow (Event id date content hour) = toRow (id, date, content, hour)


-- încarcarea event list din baza de date in server state
-- Server state-ul va ține în memorie lista de note încărcare din baza de date
newtype ServerState = ServerState { events :: IORef [Event] }



-- folosit in definirea tipului de app SpockM
--    () tipul de conexiune la baza de date (conn)
--    () tipul de sessiune (sess)
--    () tiupl state-ului serverului (st)
--    () returul monDIC`
type Server a = SpockM () () ServerState a

app :: Server ()
--
app = do
  get root $ do
    -- incarcarea evenimentelor încărcate din bază în ServerState
    events' <- getState >>= (liftIO . readIORef . events)
    -- folosim libraria lucid pentru a construi formul pagina html
    lucid $ do
      html_ (head_ (style_ "body{background-color:#FDFEFE}" ))
      h1_ [style_ "color:#737572; font-family: Roboto Condensed; padding: 20px"] "Bună ziua Petrișor"
      h2_ [style_ "color:#737572; font-family: Roboto Condensed; font-size: 18; padding: 15px"] "Evenimente planificate în perioada următoare"
      -- lista de Evenimente
      -- folosim o lista neordonata ul_ de event's si pentru fiecare to do listm data si content
      ul_ [style_ "color:##616361; font-family: Roboto Condensed;padding: 20px"]
        $ forM_ events' $ \event -> li_
        $ do
        toHtml (date event)
        "  ora:  "
        toHtml (hour event)
        "  -  "
        toHtml (content event)
      -- Addauga eveniment
      h2_ [style_ "color:#66cc33; font-family: Roboto Condensed;font-size: 18;padding: 25px"] "Adaugă un eveniment nou "
      form_ [method_ "post", style_ "padding: 25px"]
        $ do
        label_ [style_ "color: #616361; font-family: Roboto Condensed;"]
          $ do
          ""
          input_ [name_ "id", hidden_ "true", readonly_ "true", value_ "0", style_ "  width: 0px; border: none;  background: #f1f1f1a8;"]
        label_ [style_ "color: #616361; font-family: Roboto Condensed;"]
          $ do
          "Data : "
          input_ [type_ "date", name_ "date", required_ "true" ,value_ "2019-01-26", style_ "  width: 145px;  padding: 7px;  margin: 5px 20px 22px 8px;  display: inline-block;  border: none;  background: #f1f1f1a8;"]
        label_ [style_ "color: #616361; font-family: Roboto Condensed;"]
          $ do
          "Ora : "
          input_ [type_ "time", required_ "true", name_ "hour", value_ "09:00", style_ "  width: 90px;  padding: 7px;  margin: 5px 20px 22px 8px;  display: inline-block;  border: none;  background: #f1f1f1a8;"]
        label_ [style_ "color: #616361; font-family: Roboto Condensed;"]
          $ do
          "Descriere eveniment : "
          textarea_ [name_ "contents" , required_ "true" , style_ "  width: 300px; height: 62px;  padding: 7px;  margin: 4px 20px -24px 9px;  display: inline-block;  border: none;  background: #f1f1f1a8;"] ""
          input_ [type_ "submit", style_ "font-family: Roboto Condensed; background-color: #41b947; color: #ffffff;", value_ "Adaugă "]

  post root $ do
    newId <- param' "id"
    newHour <- param' "hour"
    newDate <- param' "date"
    newContents <- param' "contents"
    eventsRef <- events <$> getState
    liftIO $ atomicModifyIORef' eventsRef $ \newEvent ->
      (newEvent <> [Event newId newDate newContents newHour], ())
    redirect "/"

main :: IO ()
main = do

  -- deschidere connexiune la baza de date
  conn <- open "agenda.db"

  -- inserare date in baza de date
  -- execute conn "INSERT INTO agenda (id, date, content, hour) VALUES (?,?,?,?)" (Event 0 "2019-01-26" "Prezentare Proiect PLF" "08:00")
  -- execute conn "INSERT INTO agenda (id, date, content, hour) VALUES (?,?,?,?)" (Event 1 "2019-27-01" "Examen OOP" "10:00")
  -- execute conn "INSERT INTO agenda (id, date, content, hour) VALUES (?,?,?,?)" (Event 2 "a" "Ziua soției" "08:00")

  -- select lista de evenimente din baza de date
  r <- query_ conn "SELECT * from agenda" :: IO [Event]

  -- identificare ultimul id inserat
  rowId <- lastInsertRowId conn
  let newId = rowId + 1
  print newId

  -- se printeaza in consola
  -- mapM_ print r

  -- inchide conexiunea la baza de date
  -- close conn

  -- initializam server state-ul cu o listă de event's
  st <- ServerState <$>
   newIORef r

  -- spock configuration cfg
  -- () session configuration
  -- pool or database connection
  -- initial state st


  cfg <- defaultSpockCfg () PCNoDatabase st



  -- spock webserver :
  -- port 8080
  --(
  -- - middleware
  -- - configurare ccfg
  -- - aplicatie app
  -- )
  runSpock 8080 (spock cfg app)


-- INCERCARI

    -- SQL --
        -- execute_ conn "CREATE TABLE IF NOT EXISTS agenda (id INTEGER PRIMARY KEY, date TEXT, content TEXT)"
        -- executeNamed conn "UPDATE agenda SET str = :str WHERE id = :id" [":str" := ("updated str" :: T.Text), ":id" := rowId]
        -- execute conn "DELETE FROM agenda WHERE id = ?" (Only rowId)

    -- ServerState --

        --newIORef [ ToDo_db 1 "26/01/2019" "Prezentare Proiect PLF"
                 --, ToDo_db 2 "27/01/2019" "Examen OOP"
                 --, ToDo_db 3 "17/02/2019" "Ziua sotiei"
                 --]
    -- Old Todo --
         -- definitia obiectului event din serverstate
         --data Todo = Todo { idTodo:: Int, dateTodo :: Text, contentsTodo :: Text }

    -- Curent date --
         -- curentDate :: IO (Integer,Int,Int) -- :: (year,month,day)
         -- curentDate = getCurrentTime >>= return . toGregorian . utctDay
