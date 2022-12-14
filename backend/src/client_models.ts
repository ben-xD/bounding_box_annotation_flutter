export type AnnotationJob = {
    images: {
        thumbnail: URL,
        large: URL
    },
    id: string,
    createdOn: string
}

export type CreateAnnotationRequest = {
    annotatedOn: string
    annotationJobID: string
    boundingBoxes: string
}

export type Annotation = {
    annotationJobId: string
    boundingBoxes: string
    annotatedOn: string
}