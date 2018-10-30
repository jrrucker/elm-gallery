port module Interop exposing (send, recieve, InMessage(..), OutMessage(..))

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (decodeValue, Decoder)
import Images.Models exposing (Image, Layout)
import Commands exposing (encodeImage, layoutDecoder)


-- To JS


type OutMessage
    = HomeGalleryDetails (List Image)
    | PersonGalleryDetails (List Image)


send : OutMessage -> Cmd msg
send message =
    let
        ( images, responseType ) =
            case message of
                HomeGalleryDetails images ->
                    ( images, "HomeLayout" )

                PersonGalleryDetails images ->
                    ( images, "PersonLayout" )
    in
        List.map encodeImage images
            |> Encode.list
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
