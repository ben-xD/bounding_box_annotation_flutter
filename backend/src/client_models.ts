export type AnnotationJob = {
    imageUriOriginal: string,
    imageUriThumbnail: string,
    id: string,
    createdOn: string
}

export type CreateAnnotationRequest = {
    annotatedOn: string
    annotationJobId: string
    boundingBoxes: string
}

export type Annotation = {
    annotationJobId: string
    boundingBoxes: string
    annotatedOn: string
}