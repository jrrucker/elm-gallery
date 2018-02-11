module Commands exposing (..)

import Http
import Task exposing (Task)
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline exposing (decode, required)
import Images.Models exposing (Image, Person, ImagesContainerModel)


loadImages : String -> Task Http.Error (List Image)
loadImages albumPath =
    Http.get (albumPath ++ "/images.json") imagesDecoder
        |> Http.toTask


loadPeople : String -> Task Http.Error (List Person)
loadPeople albumPath =
    Http.get (albumPath ++ "/people.json") peopleDecoder
        |> Http.toTask


peopleDecoder : Decode.Decoder (List Person)
peopleDecoder =
    Decode.field "people" <| Decode.list personDecoder


personDecoder : Decode.Decoder Person
personDecoder =
    decode Person
        |> required "id" Decode.int
        |> required "name" Decode.string


imagesDecoder : Decode.Decoder (List Image)
imagesDecoder =
    Decode.field "images" <| Decode.list imageDecoder


imageDecoder : Decode.Decoder Image
imageDecoder =
    decode Image
        |> required "id" Decode.int
        |> required "description" Decode.string
        |> required "dateAdded" DecodeExtra.date
        |> required "thumbnail" Decode.string
        |> required "fullsize" Decode.string
        |> required "download" Decode.string
        |> required "people" (Decode.list Decode.int)
