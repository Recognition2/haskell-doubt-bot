{-# LANGUAGE OverloadedStrings #-}
module Main where

import           Data.Text                        (Text)
import qualified Data.Text                        as Text

import           Telegram.Bot.API
import           Telegram.Bot.Simple
import           Telegram.Bot.Simple.UpdateParser (updateMessageText)

type Model = ()

data Action
  = NoOp
  | Echo Text

doubtBot :: BotApp Model Action
doubtBot = BotApp
  { botInitialModel = ()
  , botAction = updateToAction
  , botHandler = handleAction
  , botJobs = []
  }

updateToAction :: Update -> Model -> Maybe Action
updateToAction update _ =
  case updateMessageText update of
    Just "/x" -> Just (Echo "Dat betwijfel ik ten zeerste")
    Just "/X" -> Just (Echo "DAT BETWIJFEL IK TEN ZEERSTE")
    Just _ -> Nothing
    Nothing   -> Nothing

handleAction :: Action -> Model -> Eff Action Model
handleAction action model = case action of
  NoOp -> pure model
  Echo msg -> model <# do
    replyText msg
    return NoOp

run :: Token -> IO ()
run token = do
  env <- defaultTelegramClientEnv token
  startBot_ (conversationBot updateChatId doubtBot) env

main :: IO ()
main = do
  putStrLn "Please, enter Telegram bot's API token:"
  token <- Token . Text.pack <$> getLine
  run token
