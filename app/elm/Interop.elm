port module Interop exposing (InMessage(..), OutMessage(..), recieve, send)

import Commands exposing (encodeImage, layoutDecoder)
import Images.Models exposing (Image, Layout)
import Json.Decode as Decode exposing (Decoder, decodeValue)
import Json.Encode as Encode exposing (Value)



-- To JS


type OutMessage
    = HomeGalleryDetails (List Image)
    | PersonGalleryDetails (List Image)


send : OutMessage -> Cmd msg
send message =
    let
        ( images, responseType ) =
            case message of
                HomeGalleryDetails homeImages ->
                    ( homeImages, "HomeLayout" )

                PersonGalleryDetails personImages ->
                    ( personImages, "PersonLayout" )
    in
    Encode.list encodeImage images
        |> encodeAs "GalleryDetails" responseType
        |> toJs


encodeAs : String -> String -> Value -> Value
encodeAs msgType responseType data =
    Encode.object
        [ ( "type", Encode.string msgType )
        , ( "responseType", Encode.string responseType )
        , ( "data", data )
        ]


port toJs : Value -> Cmd msg



-- From JS


port fromJs : (Value -> msg) -> Sub msg


type InMessage
    = HomeLayout Layout
    | PersonLayout Layout
    | Unknown


recieve : (InMessage -> msg) -> Sub msg
recieve msg =
    fromJs
        (\value ->
            decodeValue inMessageDecoder value
                |> Debug.log "Parse Result"
                |> Result.withDefault Unknown
                |> msg
        )


inMessageDecoder : Decoder InMessage
inMessageDecoder =
    Decode.field "type" Decode.string
        |> Decode.andThen
            (\msgType ->
                case msgType of
                    "HomeLayout" ->
                        Decode.map HomeLayout (Decode.field "data" layoutDecoder)

                    "PersonLayout" ->
                        Decode.map PersonLayout (Decode.field "data" layoutDecoder)

                    _ ->
                        Decode.succeed Unknown
            )
