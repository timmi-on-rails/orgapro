module UserSettings exposing (UserSettings, decode)

import Json.Decode as D
import Json.Encode as E


type alias UserSettings =
    { projectUrl : String
    , apiKey : String
    }


decode : E.Value -> Result String UserSettings
decode value =
    case D.decodeValue decoder value of
        Ok cfg ->
            Ok cfg

        Err err ->
            Err <| D.errorToString err


decoder : D.Decoder UserSettings
decoder =
    D.map2 UserSettings
        (D.field "user" D.string)
        (D.field "password" D.string)
