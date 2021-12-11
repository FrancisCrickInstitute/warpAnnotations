/* ****************************************************************************************************************** */
/* parseNml.c                                    NML parser for Knossos and webKnossos (formerly Oxalis)              */
/* Copyright 2013, 2014, 2015, 2016, 2017, 2018  Max Planck Institute for Brain Research, Frankfurt                   */
/* Version 0.35                                  Martin Zauser                                                        */
/* ****************************************************************************************************************** */

/* 26.07.2013   V0.10   MAX_NUMBER_OF_COMMENTS increased from 2000 to 8000 because iris tracing is ~3000 */
/* 03.03.2014   V0.12   added third parameter 'nodesAsStruct is cell'                                    */
/* 16.04.2014   V0.13   MAX_NUMBER_OF_NODES increased from 600000 to 1200000                             */
/*                          print warning if node id of a comment does not exist (and ignore comment)    */
/* 02.08.2015   V0.14   MAX_NUMBER_OF_BRANCHPOINTS increased from 2000 to 20000                          */
/* 20.09.2015   V0.15   added function parameters 'use inVp' and 'nodeCoordinateOffset'                  */
/* 01.10.2015   V0.16   bugfix: if 'use inVp' is zero the following values are now in column 9.. (not 6) */
/* 11.11.2015   V0.17   added: listing of comments                                                       */
/* 16.11.2015   V0.18   added: task id and direct link to the file for listing the comments              */
/* 17.11.2015   V0.19   added: direct link also as plain text (for non-MATLAB users)                     */
/* 18.11.2015   V0.20   included compiler directives for linux compilers (no comment listing mode)       */
/* 20.11.2015   V0.21   bugfix: infinite loop for non-listing-mode removed                               */
/* 21.12.2015   V0.22   added: selection mode (coordinates can be limited in x, y, or z direction)       */
/* 26.12.2015   V0.23   changed: ignore illegal edges (id = 0) in selection mode without stopping        */
/* 26.12.2015   V0.24   changed: allow node and edges with id = 0 in selection mode                      */
/* 18.01.2016   V0.25   changed: renumbering of nodes in select mode                                     */
/* 16.02.2016   V0.26   added: function parameter 'filenameOutput' (default: results.nml)                */
/* 28.04.2016   V0.27   added: Mac OS support                                                            */
/* 18.08.2016   V0.28   added: attributes rotX, rotY, rotZ, bitDepth, interpolation, withSpeed           */
/* 20.08.2016   V0.29   changed: moved attributes rotX, rotY, rotZ ... to the end of the list            */
/* 20.08.2016   V0.30   changed: attribute time at the end of the list                                   */
/* 28.09.2016   V0.31   added: change automatically to slow mode if node id > MAX_NUMBER_OF_NODES        */
/* 30.10.2016   V0.32   changed: for loops with local counting variables (otherwise error on Mac OS)     */
/* 08.01.2018   V0.33   bugfix: handle closing tags in <parameter> section correctly                     */
/* 14.10.2018   V0.34   bugfix: correct parameter type for mxCreateCellArray (mwSize instead of int)     */
/* 16.10.2018   V0.35   bugfix: test variables of version 0.34 removed                                   */

/* parseNml XML-Parser */
#include "mex.h"
#include <stdio.h>
#include <string.h>
#include <time.h>
#if !defined(__linux__) && !defined(__APPLE__)
    #include "windows.h"
#endif

#define VERSION       "0.35"
#define VERSION_DATE  "16.10.2018"

/* without DEBUG_MODE for high speed parsing (for DEBUG_MODE just uncomment the following line) */
/* #define DEBUG_MODE */

#define FILENAME_OUTPUT_SELECT_MODE  "results.nml"

/* memory variables */
#define MEMORY_SIZE              40000000
#define MAX_NUMBER_OF_ELEMENTS     600000
#define MAX_NUMBER_OF_ATTRIBUTES     1000
#define MAX_NUMBER_OF_NODES       1200000
#define MAX_NUMBER_OF_EDGES        600000
#define MAX_NUMBER_OF_BRANCHPOINTS  20000
#define MAX_NUMBER_OF_THINGS         3000
#define MAX_NUMBER_OF_PARAMETERS       50
#define MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL  200
#define MAX_NUMBER_OF_COMMENTS       8000

/* definition of compiler standards */
#if defined(__APPLE__)
    #define LOOP_VAR int
#else
    #define LOOP_VAR
#endif


char nmlMemory[MEMORY_SIZE];
char *pElementList[MAX_NUMBER_OF_ELEMENTS];
int iNumberOfAttributes[MAX_NUMBER_OF_ELEMENTS];
char *pAttributeName[MAX_NUMBER_OF_ATTRIBUTES];
char *pAttributeValue[MAX_NUMBER_OF_ATTRIBUTES];
long int gMemorypointer;
long int gMemorypointerCurrent;
long int nmlElementCounter;
long int nmlAttributeCounter;
long int nmlParameterCounter;
long int nmlThingCounter;
long int nmlThingCounterOffset;
long int nmlThingCounterAllFiles;
long int nmlCommentCounter;
int iNumberOfParameterAttributes[MAX_NUMBER_OF_PARAMETERS];
char *pParameterName[MAX_NUMBER_OF_PARAMETERS];
char *pParameterAttributeName[MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL];
char *pParameterAttributeValue[MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL];
long int gLineCounter;
#define NUM_OF_NODE_ATTRIBUTES_NML_FILE 14
double dNode[MAX_NUMBER_OF_NODES][NUM_OF_NODE_ATTRIBUTES_NML_FILE];
int bNodeIdConversionFastMode;
int iNode;
int iNodeIdConversion[MAX_NUMBER_OF_NODES + 1]; /* +1 because it starts with 0 */
int iNodeIdConversionAllThings[MAX_NUMBER_OF_NODES + 1]; /* +1 because it starts with 0 */
char *pNode[MAX_NUMBER_OF_NODES][NUM_OF_NODE_ATTRIBUTES_NML_FILE];
char *pNodeComment[MAX_NUMBER_OF_NODES];
int bNodeFound;
int iEdge[MAX_NUMBER_OF_EDGES][2];
int iBranchpoint[MAX_NUMBER_OF_BRANCHPOINTS];
double dThingID[MAX_NUMBER_OF_THINGS];
char *pThingName[MAX_NUMBER_OF_THINGS];
int iCommentNodeID[MAX_NUMBER_OF_COMMENTS];
char *pCommentContent[MAX_NUMBER_OF_COMMENTS];
int iNumberOfNodes;
int iNumberOfNodesThing[MAX_NUMBER_OF_THINGS];
int iNumberOfEdges;
int iNumberOfEdgesSelected;
int iNumberOfEdgesThing[MAX_NUMBER_OF_THINGS];
int iNumberOfBranchpoints;
double dNodeCoordinateOffset;
int iFileCounter;
/* input-output variables */
#define MESSAGE_BUFFER_SIZE   200
#define VALUE_BUFFER_SIZE     100
char szMessageBuffer[MESSAGE_BUFFER_SIZE];
char szValueBuffer[VALUE_BUFFER_SIZE];
/* element variables */
#define MAX_LENGTH_NMLELEMENT       100
#define MAX_LENGTH_ATTRIBUTE_NAME   100
#define MAX_LENGTH_ATTRIBUTE_VALUE  100
char szNmlElement[MAX_LENGTH_NMLELEMENT + 1 + 1];  /* +1 for ending slash and +1 for ending zero */
int statusElementClosed; /* 0 if open, 1 if closed with backslash */

/* prototypes */
void mexFunction (int nlhs , mxArray *plhs[], int nrhs , const mxArray *prhs[]);
int readCharacterFromFile (FILE* file);
int readNmlElement (FILE* file);
int readNmlString (FILE* file, char *szEndOfElement, char **pString);
int getIntegerAttribute (const char *szAttribute, int *iValue, int bShowErrorMessage);
int getDoubleAttribute (const char *szAttribute, double *dValue, char **pAttribute, int bShowErrorMessage, int bCheckForBoolean, int bOptionalAttribute);
int getStringAttribute (const char *szAttribute, char **pAttribute, int bShowErrorMessage);

/* DEBUG_MODE defines */
#ifdef DEBUG_MODE
    #define getCharacter readCharacterFromFile
#else
    #define getCharacter fgetc
#endif

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~          CONSTANTS         ~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* coding sections */
#define SECTION_MAIN                1
#define SECTION_READNMLSTRING       2
#define SECTION_READNMLELEMENT      3
#define SECTION_COMMENTSSTRING      4
#define SECTION_BRANCHPOINTSSTRING  5

/* error codes */
#define ERROR_OUT_OF_MEMORY         1

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~          FUNCTIONS         ~~~~~~~~~~~~~~~~ */
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */ 

/* error function */
void errorMessage (int iCodingSection, int iErrorType) {
    /* define text for coding section */
    switch (iCodingSection) {
        case SECTION_READNMLSTRING:
            sprintf(szMessageBuffer, "Braintracing:parseNML:readNmlString");
            break;
        case SECTION_READNMLELEMENT:
            sprintf(szMessageBuffer, "Braintracing:parseNML:readNmlElement");
            break;
        case SECTION_COMMENTSSTRING:
            sprintf(szMessageBuffer, "Braintracing:parseNML:commentsString");
            break;
        case SECTION_BRANCHPOINTSSTRING:
            sprintf(szMessageBuffer, "Braintracing:parseNML:branchpointsString");
            break;
        case SECTION_MAIN:
        default:
            sprintf(szMessageBuffer, "Braintracing:parseNML:mainFunction");
            break;
    }
    /* send error message */
    switch (iErrorType) {
        case ERROR_OUT_OF_MEMORY:
            if (iCodingSection == SECTION_COMMENTSSTRING) {
                mexErrMsgIdAndTxt(szMessageBuffer, "Out of memory. Cannot write comments. Please increase constant MEMORY_SIZE (line 22).");
            } else {
                mexErrMsgIdAndTxt(szMessageBuffer, "Out of memory. Please increase constant MEMORY_SIZE (line 22).");
            }
            break;
        default:
            mexErrMsgIdAndTxt(szMessageBuffer, "Unknown internal error.");
            break;
    }
    return;
}

/* read character from file (DEBUG_MODE) */
int readCharacterFromFile (FILE* file) {
    int character;
    character = fgetc (file);
    if (character == 0x0A) {
        gLineCounter++;
    }
    return character;
}

/* read attribute as integer value from memory (from last element) */
int getIntegerAttribute (const char *szAttribute, int *iValue, int bShowErrorMessage) {
    int i;
    int bFoundAttributeName;

    /* initialize value */
    *iValue = 0;

    /* initialize other variables */
    bFoundAttributeName = false;

    /* check number of elements */
    if (nmlElementCounter <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getIntegerAttribute", "No elements available.");
        return 1;
    }

    /* check number of attributes */
    if (iNumberOfAttributes[nmlElementCounter - 1] <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getIntegerAttribute", "No attributes available.");
        return 1;
    }

    /* search attribute name */
    for (LOOP_VAR i = 0; i < iNumberOfAttributes[nmlElementCounter - 1]; i++) {
        if (strcmp(pAttributeName[i], szAttribute) == 0) {
            /* convert attribute value to double */
            *iValue = atoi(pAttributeValue[i]);
            /* set "found" flag */
            bFoundAttributeName = true;
            break;
        }
    }

    /* attribute name not found */
    if (!bFoundAttributeName) {
        if (bShowErrorMessage) {
            /* show line number in debug mode */
            #ifdef DEBUG_MODE
                sprintf(szMessageBuffer, "Attribute %s not found in line %ld.", szAttribute, gLineCounter);
            #else
                sprintf(szMessageBuffer, "Attribute %s not found.", szAttribute);
            #endif
            mexErrMsgIdAndTxt("Braintracing:parseNML:getIntegerAttribute", szMessageBuffer);
        }
        return 1;
    }

    /* return OK */
    return 0;
}


/* read attribute as double value from memory (from last element) */
int getDoubleAttribute (const char *szAttribute, double *dValue, char **pAttribute, int bShowErrorMessage, int bCheckForBoolean, int bOptionalAttribute) {
    int i;
    int bFoundAttributeName;

    /* initialize value */
    *dValue = 0;
    *pAttribute = NULL;

    /* initialize other variables */
    bFoundAttributeName = false;
 
    /* check number of elements */
    if (nmlElementCounter <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getDoubleAttribute", "No elements available.");
        return 1;
    }

    /* check number of attributes */
    if (iNumberOfAttributes[nmlElementCounter - 1] <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getDoubleAttribute", "No attributes available.");
        return 1;
    }

    /* search attribute name */
    for (LOOP_VAR i = 0; i < iNumberOfAttributes[nmlElementCounter - 1]; i++) {
        if (strcmp(pAttributeName[i], szAttribute) == 0) {
            /* store pointer */
            *pAttribute = pAttributeValue[i];
            /* check for true/false */
            if (bCheckForBoolean)
            {
                /* default: false => search only for true, TRUE or True */
                if ((strcmp(pAttributeValue[i], "true") == 0) || (strcmp(pAttributeValue[i], "TRUE") == 0) || (strcmp(pAttributeValue[i], "True") == 0))
                     *dValue = 1;
                else *dValue = atof(pAttributeValue[i]);
            }
            else
            {
                /* convert attribute value to double */
                *dValue = atof(pAttributeValue[i]);
            }
            /* set "found" flag */
            bFoundAttributeName = true;
            break;
        }
    }

    /* attribute name not found */
    if (!bFoundAttributeName) {
        if ((bShowErrorMessage) && (!bOptionalAttribute)) {
            /* show line number in debug mode */
            #ifdef DEBUG_MODE
                sprintf(szMessageBuffer, "Attribute %s not found in line %ld.", szAttribute, gLineCounter);
            #else
                sprintf(szMessageBuffer, "Attribute %s not found.", szAttribute);
            #endif
            mexErrMsgIdAndTxt("Braintracing:parseNML:getDoubleAttribute", szMessageBuffer);
        }
        return 1;
    }

    /* return OK */
    return 0;
}

/* read attribute as string value from memory (from last element) */
int getStringAttribute (const char *szAttribute, char **pAttribute, int bShowErrorMessage) {
    int i;
    int bFoundAttributeName;

    /* initialize value */
    *pAttribute = NULL;

    /* initialize other variables */
    bFoundAttributeName = false;

    /* check number of elements */
    if (nmlElementCounter <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getStringAttribute", "No elements available.");
        return 1;
    }

    /* check number of attributes */
    if (iNumberOfAttributes[nmlElementCounter - 1] <= 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:getStringAttribute", "No attributes available.");
        return 1;
    }

    /* search attribute name */
    for (LOOP_VAR i = 0; i < iNumberOfAttributes[nmlElementCounter - 1]; i++) {
        if (strcmp(pAttributeName[i], szAttribute) == 0) {
            /* store pointer */
            *pAttribute = pAttributeValue[i];
            /* set "found" flag */
            bFoundAttributeName = true;
            break;
        }
    }

    /* attribute name not found */
    if (!bFoundAttributeName) {
        if (bShowErrorMessage) {
            /* show line number in debug mode */
            #ifdef DEBUG_MODE
                sprintf(szMessageBuffer, "Attribute %s not found in line %ld.", szAttribute, gLineCounter);
            #else
                sprintf(szMessageBuffer, "Attribute %s not found.", szAttribute);
            #endif
            mexErrMsgIdAndTxt("Braintracing:parseNML:getStringAttribute", szMessageBuffer);
        }
        /* return NOT OK */
        return 1;
    }

    /* return OK */
    return 0;
}

/* read single string until end and set pointer to string */
int readNmlString (FILE* file, char *szEndOfElement, char **pString) {
    char c;
    int iLengthEndOfString;
    int bRemoveSpaces;
    int bBeginning;
    long int gMemorypointerEnd;
    int i;
    /* store memory pointer */
    *pString = &nmlMemory[gMemorypointer];
    i = 0;
    gMemorypointerEnd = gMemorypointer;
    bRemoveSpaces = 1; /* 1 = section between > and <   0 = section between < and >  */
    bBeginning = 1;
    do {
        c = getCharacter (file);
        if (c == EOF) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlString", "Unexpected end of file in XML element.");
            return 1;
        }
        /* check for beginning */
        if (bBeginning) {
            if ((c == ' ') || (c == 0x09) || (c == 0x0D) || (c == 0x0A) || (c == 0x00)) {
                continue;
            }
            /* end of beginning ;-) */
            bBeginning = 0;
        }
        /* check for end */
        if ((i == 0) && (c == '>')) {
            gMemorypointerEnd = gMemorypointer;
        }
        /* check for "space mode" --> remove spaces and tabs between > and < */
        if (((c == ' ') || (c == 0x09)) && bRemoveSpaces) {
            continue;
        }
        if (bRemoveSpaces) {
            if (c == '<') {
                bRemoveSpaces = 0;
            }
        } else {
            if (c == '>') {
                bRemoveSpaces = 1;
            }
        }
        /* store character in memory */
        if (gMemorypointer >= MEMORY_SIZE) {
            errorMessage(SECTION_READNMLSTRING, ERROR_OUT_OF_MEMORY);
            return 1;
        }
        nmlMemory[gMemorypointer++] = c;
        /* check for < sign */
        if (i == 0) {
            if (c == '<') {
                i = 1;
                iLengthEndOfString = 1;
            }
            continue;
        }
        /* check for end of element */
        if ((i == 1) || (i == (strlen(szEndOfElement) + 1))) {
            if (c == ' ') {
                iLengthEndOfString++;
                continue;
            }
            if ((i == (strlen(szEndOfElement) + 1)) && (c == '>')) {
                /* found end of element */
                /* correct memory pointer */
                gMemorypointer -= (iLengthEndOfString + 1);
                /* remove whitespaces from the end */
                if ((gMemorypointerEnd + 1) <= gMemorypointer) {
                    while (((gMemorypointerEnd + 1) <= gMemorypointer) && ((nmlMemory[gMemorypointer - 1] == ' ') ||
                            (nmlMemory[gMemorypointer - 1] == 0x0D) || (nmlMemory[gMemorypointer - 1] == 0x0A) ||
                            (nmlMemory[gMemorypointer - 1] == 0x09) || (nmlMemory[gMemorypointer - 1] == 0x00))) {
                        gMemorypointer--;
                    }
                }
                /* store trailing zero in memory */
                nmlMemory[gMemorypointer++] = 0;
                /* return OK; */
                return 0;
            }
        }
        /* compare string */
        if (c == szEndOfElement[i - 1]) {
            i++;
            iLengthEndOfString++;
        } else {
            i = 0;
            iLengthEndOfString = 0;
        }
    } while (1);
    /* dummy return */
    return 1;
}


/* read single NML element (if an ending slash exists it will be added to the name of the element !!!  <name id="xx" value=0"/> --> "name/") */
int readNmlElement (FILE* file) {
    char c;
    int i;
    int iEndOfElement;
    char cTypeOfQuotationMark;
    /* delete previous element */
    szNmlElement[0] = 0;
    statusElementClosed = 0; /* 0 = open */

    /* read leading '<' */
    i = 0;
    do {
        c = getCharacter (file);
        if (c == EOF) {
            /* reached end of file --> return empty element */
            return 0;
        }
    } while (c != '<');

    /* read element name (i = number of characters) */
    do {
        /* read character */
        c = getCharacter (file);
        if (c == EOF) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
            return 1;
        }

        /* check for special parameters beginning with ? and ignore it (for example: ?xml version="1.0") */
        /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ?xml special >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
        if ((i == 0) && (c == '?')) {
            do {
                c = getCharacter (file);
                if (c == EOF) {
                    mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                    return 1;
                }
            } while (c != '>');
            /* read leading '<' again */
            do {
                c = getCharacter (file);
                if (c == EOF) {
                    /* reached end of file --> return empty element */
                    return 0; 
                }
            } while (c != '<');
            /* read first character of element name again */
            c = getCharacter (file);
            if (c == EOF) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
        }
        /* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ?xml special >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

        /* store character */
        if ((c != ' ') && (c != 0x00) && (c != 0x09) && (c != 0x0A) && (c != 0x0D) && (c != '>')) {
            /* +++++++++++++++++++++++++ */
            /* +++ element found !!! +++ */
            /* +++++++++++++++++++++++++ */
            /* store element pointer */
            if (i == 0) {
                if (nmlElementCounter >= MAX_NUMBER_OF_ELEMENTS) {
                    mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Two many elements Please increase MAX_NUMBER_OF_ELEMENTS.");
                    return 1;
                }
                /* store element pointer */
                pElementList[nmlElementCounter] = &nmlMemory[gMemorypointer];
                /* reset number of attributes */
                iNumberOfAttributes[nmlElementCounter] = 0;
            } 
            /* store character */
            szNmlElement[i++] = c;
            /* store character in memory */
            if (gMemorypointer >= MEMORY_SIZE) {
                errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                return 1;
            }
            nmlMemory[gMemorypointer++] = c;
        }
        /* check length */
        if (i >= MAX_LENGTH_NMLELEMENT) {
            szNmlElement[MAX_LENGTH_NMLELEMENT] = 0;
            sprintf(szMessageBuffer, "NML element too long: %s... Maximal length is %d characters.\n", szNmlElement, MAX_LENGTH_NMLELEMENT);
            mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", szMessageBuffer);
            return 1;
        }
    } while ((c != ' ') && (c != 0x00) && (c != 0x09) && (c != 0x0A) && (c != 0x0D) && (c != '>'));
    /* set trailing zero (name of element is now available in 'szNmlElement') */
    iEndOfElement = i;
    szNmlElement[i] = 0;
    /* store trailing zero in memory */
    if (gMemorypointer >= MEMORY_SIZE) {
        errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
        return 1;
    }
    nmlMemory[gMemorypointer++] = 0;

    /* check element size (has to be at least 1 character) */
    if (i == 0) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Empty NML element. Leading spaces not allowed in NML element.");
        return 1;
    }

    /* no attributes? fine, then return without attributes ;-) */
    if (c == '>') {
        /* store double trailing zero in memory */
        if (gMemorypointer >= MEMORY_SIZE) {
            errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
            return 1;
        }
        nmlMemory[gMemorypointer++] = 0;
        /* increase element counter */
        nmlElementCounter++;
        /* return OK */
        return 0; 
    }

    /* loop: read all attribute names and values */
    do {
        /* read attribute name */
        i = 0;
        do {
            c = getCharacter (file);
            if (c == EOF) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
            /* ending slash --> add slash to name of element !!! */
            if ((c == '/') && (i == 0)) {
                szNmlElement[iEndOfElement] = c;
                szNmlElement[iEndOfElement + 1] = 0;
                statusElementClosed = 1;  /* 1 = closed */
                /* store slash in memory */
                if (gMemorypointer >= MEMORY_SIZE) {
                    errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                    return 1;
                }
                nmlMemory[gMemorypointer++] = c;
                /* read '>' */
                do {
                    c = getCharacter (file);
                    if (c == EOF) {
                        mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                        return 1;
                    }
                } while (c != '>');
                /* store double trailing zero in memory */
                if (gMemorypointer >= MEMORY_SIZE) {
                    errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                    return 1;
                }
                nmlMemory[gMemorypointer++] = 0;
                /* increase element counter */
                nmlElementCounter++;
                /* return OK */
                return 0;
            }
            /* end of element --> error, if there is an attribute without '=' */
            if (c == '>') {
                if (i == 0) {
                    /* store double trailing zero in memory */
                    if (gMemorypointer >= MEMORY_SIZE) {
                        errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                        return 1;
                    }
                    nmlMemory[gMemorypointer++] = 0;
                    /* increase element counter */
                    nmlElementCounter++;
                    /* return OK */
                    return 0;
                }
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
            /* store attribute name (ignore spaces in attribute name) */
            if ((c != ' ') && (c != 0x00) && (c != 0x09) && (c != 0x0A) && (c != 0x0D) && (c != '=')) {
                /* check forbidden characters */
                if ((c == '>') || (c == '/')) {
                    sprintf(szMessageBuffer, "Forbidden character in attribute name. May be attribute value is missing.\n");
                    mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", szMessageBuffer);
                    return 1;
                }
                /* check max number of attributes */
                if (i == 0) {
                    if (nmlAttributeCounter >= MAX_NUMBER_OF_ATTRIBUTES) {
                        sprintf(szMessageBuffer, "Too many attributes in element %s.\n", szNmlElement);
                        mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", szMessageBuffer);
                        return 1;
                    }
                    /* store pointer to attribute name */
                    pAttributeName[nmlAttributeCounter] = &nmlMemory[gMemorypointer];
                }
                i++;
                /* store character in memory */
                if (gMemorypointer >= MEMORY_SIZE) {
                    errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                    return 1;
                }
                nmlMemory[gMemorypointer++] = c;
            }
        } while (c != '=');
        /* store double zero in memory */
        if (gMemorypointer >= MEMORY_SIZE) {
            errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
            return 1;
        }
        nmlMemory[gMemorypointer++] = 0;

        /* *********** QUOTATION MARK ********** */
        /* read quotation mark and ignore spaces */
        do {
            c = getCharacter (file);
            if (c == EOF) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
        } while ((c == ' ') || (c == 0x00) || (c == 0x09) || (c == 0x0A) || (c == 0x0D));
        /* check quotation mark " (hex22) or ' (hex27) */
        if ((c != 0x22) && (c != 0x27)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Argument value is missing. Quotation mark expected. Forgot it?");
            return 1;
        }
        /* remember type of quotation mark */
        cTypeOfQuotationMark = c;

        /* reset character counter */
        i = 0; 

        /* read attribute value */
        do {
            c = getCharacter (file);
            if (c == EOF) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Unexpected end of file in XML element.");
                return 1;
            }
            /* store character */
            if (c != cTypeOfQuotationMark) {
                /* store pointer to attribute value */
                if (i == 0) {
                    pAttributeValue[nmlAttributeCounter] = &nmlMemory[gMemorypointer];
                }
                i++;
                /* store character in memory */
                if (gMemorypointer >= MEMORY_SIZE) {
                    errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
                    return 1;
                }
                nmlMemory[gMemorypointer++] = c;
            }
        } while (c != cTypeOfQuotationMark);
        /* increase number of attributes per element and attribute counter */
        iNumberOfAttributes[nmlElementCounter]++;
        nmlAttributeCounter++;
        /* store double zero in memory */
        if (gMemorypointer >= MEMORY_SIZE) {
            errorMessage(SECTION_READNMLELEMENT, ERROR_OUT_OF_MEMORY);
            return 1;
        }
        nmlMemory[gMemorypointer++] = 0;

    } while (1);  /* endless loop --> reading attributes */

    /* dummy return value (to avoid warnings) */
    return 1;
}

void mexFunction (int nlhs , mxArray *plhs[], int nrhs , const mxArray *prhs[]) {

    /* declare variables */
    #define MAX_LENGTH_FILENAME  255
    #define MAX_LENGTH_PATH      4096
    char szPathAndFilename[MAX_LENGTH_FILENAME + MAX_LENGTH_PATH + 1];
    char szFilename[MAX_LENGTH_FILENAME + 1];
    char szPath[MAX_LENGTH_PATH + 1];
    char szPathCommentFiles[MAX_LENGTH_FILENAME + MAX_LENGTH_PATH + 1 + 6]; /* plus \*.nml => 6 characters */
    char szPathAndFilenameCommentFiles[MAX_LENGTH_FILENAME + MAX_LENGTH_PATH + 1 + MAX_LENGTH_FILENAME + 1];
    char szPathAndFilenameOutput[MAX_LENGTH_FILENAME + MAX_LENGTH_PATH + 1];
    mxArray *mxGetFileOutput[2];
    mxArray *mxGetFileInput[2];
    const char *nmlStructFirstThing[] = { "parameters", "nodes", "nodesAsStruct", "nodesNumDataAll",
                                          "edges", "thingID", "name", "commentsString", "branchpointsString", "branchpoints"};
    const char *nmlStructLastThing[] = { "nodes", "nodesAsStruct", "nodesNumDataAll", "edges", "thingID", "name", "commentsString"};
    const char *nmlStructOtherThings[] = { "nodes", "nodesAsStruct", "nodesNumDataAll", "edges", "thingID", "name"};
    const char *nmlNodeAttributes[] = { "id", "radius", "x", "y", "z", "inVp", "inMag", "rotX", "rotY", "rotZ", "bitDepth", "interpolation", "withSpeed", "time", "comment"};
    int nmlNodeAttributesOptional[] = { 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0 };
    const char *nmlEdgeAttributes[] = { "source", "target" };
    const char *nmlBranchpointAttributes[] = { "id" };
    int nmlNodeAttributeOrder[] = { 2, 3, 4, 1 };
    int nmlNodeAttributeOrderNmlFile[] = { 1, 2, 3, 4 };
    #define NUM_OF_NODE_ATTRIBUTES_ALL     (sizeof (nmlNodeAttributes) / sizeof (const char *))
    #define NUM_OF_NODE_ATTRIBUTES         (sizeof (nmlNodeAttributeOrder) / sizeof (int))
    #define NUM_OF_EDGE_ATTRIBUTES         (sizeof (nmlEdgeAttributes) / sizeof (const char *))
    #define NUM_OF_BRANCHPOINT_ATTRIBUTES  (sizeof (nmlBranchpointAttributes) / sizeof (const char *))
    int iIsActive[NUM_OF_NODE_ATTRIBUTES_ALL];
    int iIsCoordinate[NUM_OF_NODE_ATTRIBUTES_ALL];
    /* general variables */
    int i, j, k, m;
    double d;
    char *p;
    time_t time_start;
    int iNodeIdFoundSource;
    int iNodeIdFoundTarget;
    int iNodeIdOriginal;
    int iGlobalNodeId;
    int iGlobalNodeIdStart;
    int iNodeExists;
    int iLength;
    int iNumberOfBytesWritten;
    int iIllegalEdge;
    int bCommentsAvailable;
    int bNoOptionalArgumentsFound;
    int iNumberOfNodesOffset;
    int iNumberOfEdgesOffset;
    mwSize iDimensions[1];
    mwSize iDimensionsNodes[2];
    int iKeepNodeAsStruct;
    int iNodesAsStructIsCell;
    int iNodeIDConverted;
    int iUseInVp;
    int iNextFile;
    int iNextFileSelectMode;
    int iParameterDone;
    long int nmlElementCounterCurrent;
    /* variables for comment listing */
    int iListComments;
    int iSelectMode;
    double dSelectMinX;
    double dSelectMaxX;
    double dSelectMinY;
    double dSelectMaxY;
    double dSelectMinZ;
    double dSelectMaxZ;
    int iNodeInSelectedArea;
    char c;
    int iCountCharacters;
    #define URL_WEBKNOSSOS          "https://webknossos.brain.mpg.de/annotations/CompoundTask/"
    #define LENGTH_MONGODB_ID       24
    #define LENGTH_MONGODB_ID_SHORT  6
    char szTaskId[LENGTH_MONGODB_ID + 1]; /* the task id is a typical mongoDB is with 12 bytes = 24 hex characters (plus 1 for the trailing zero) */

    /* xml variables */
    FILE* file;
    FILE* fileOutput;

    /* MATLAB variables */
    mwSize mwPointer;
    mxArray *nmlCell;
    mxArray *nmlCellCommentsString;
    mxArray *nmlCellLastCommentsString;
    mxArray *nmlCellBranchpointsString;
    mxArray *nmlStruct[MAX_NUMBER_OF_THINGS];
    mxArray *nmlParameterElementStruct;
    mxArray *nmlParameterAttributeStruct;
    mxArray *nmlCellNodeAsStruct[MAX_NUMBER_OF_THINGS];
    mxArray *nmlStructNodeAsStruct[MAX_NUMBER_OF_NODES];
    mxArray *nmlArrayNodesNumDataAll[MAX_NUMBER_OF_THINGS];
    double  *pArrayNodesNumDataAll;
    mxArray *nmlArrayNodes[MAX_NUMBER_OF_THINGS];
    double  *pArrayNodes;
    mxArray *nmlArrayEdges[MAX_NUMBER_OF_THINGS];
    double  *pArrayEdges;
    mxArray *nmlArrayBranchpoints;
    double  *pArrayBranchpoints;

    /* directory and file variables */
    #if !defined(__linux__) && !defined(__APPLE__)
        HANDLE fileHandle;
        WIN32_FIND_DATA windowsFindData;
    #endif

    /* send welcome message */
    printf("This is Braintracing NML parser version %s, Copyright 2018 MPI for Brain Research, Frankfurt.\n", VERSION);

    if (MAX_NUMBER_OF_EDGES > MAX_NUMBER_OF_NODES) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:InternalError", "Internal Error:  MAX_NUMBER_OF_NODES has to be larger than MAX_NUMBER_OF_EDGES.");
        return;
    }

    /* check number of input arguments */
    if (nrhs > 10) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:nrhs", "Only ten parameters allowed: filename[character], keepNodeAsStruct[0/1], nodesAsStruct is cell[0/1] "
                          "use inVP[0/1], nodeCoordinateOffset[double] (for webKnossos use offset 1), listComments[0/1]"
                          ", selectMode[0/1=x/2=y/3=z], coordinateMin[double], coordinateMax[double], filenameOutput[character].");
        return;
    }
    if (nrhs < 1) {
        /* ************ */
        /* get filename */
        /* ************ */
        mxGetFileInput[0] = mxCreateString ("*.nml");
        mxGetFileInput[1] = mxCreateString ("Please select KNOSSOS or webKnossos .nml file");
        /* open file dialog */
        if (mexCallMATLAB(2, mxGetFileOutput, 2, mxGetFileInput, "uigetfile")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FileDialog", "Filename missing. Could not select file.");
            return;
        }
        /* check for user abort */
        if ((mxIsClass(mxGetFileOutput[0], "double")) && (mxGetScalar(mxGetFileOutput[0]) == 0)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FileDialog", "Filename missing. File dialog canceled by user.");
            return;
        }
        if (mxGetString(mxGetFileOutput[0], szFilename, MAX_LENGTH_FILENAME)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FileDialog", "Filename invalid or too long.");
            return;
        }
        if (mxGetString(mxGetFileOutput[1], szPath, MAX_LENGTH_PATH)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FileDialog", "Path invalid or too long.");
            return;
        }
        /* concatenate path and filename */
        sprintf(szPathAndFilename, "%s%s", szPath, szFilename);

    } else {
        /* check type of input argument */
        if( !mxIsClass(prhs[0], "char")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notString", "Input parameter 'filename' must be a string.");
            return;
        }

        /* get file name */
        if (mxGetString(prhs[0], szPathAndFilename, MAX_LENGTH_FILENAME)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FilenameTooLong", "Input parameter 'filename' too long.");
            return;
        }
    }

    /* intialize optional parameters */
    iKeepNodeAsStruct = 1;
    /* check second argument */
    if (nrhs >= 2) {
        /* check type of second input argument */
        if (!mxIsClass(prhs[1], "double")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notString", "Input parameter 'keepNodeAsStruct' must be 0 or 1.");
            return;
        }
        /* get parameter */
        iKeepNodeAsStruct = (int)mxGetScalar(prhs[1]);
    }

    iNodesAsStructIsCell = 1;
    /* check third argument */
    if (nrhs >= 3) {
        /* check type of third input argument */
        if (!mxIsClass(prhs[2], "double")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notBinary", "Input parameter 'nodesAsStruct is cell' must be 0 or 1.");
            return;
        }
        /* get parameter */
        iNodesAsStructIsCell = (int)mxGetScalar(prhs[2]);
        /* check parameter */
        if ((iNodesAsStructIsCell < 0) || (iNodesAsStructIsCell > 1)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notBinary", "Input parameter 'nodesAsStruct is cell' must be 0 or 1.");
            return;
        }
    }

    iUseInVp = 1;
    /* check fourth argument */
    if (nrhs >= 4) {
        /* check type of third input argument */
        if (!mxIsClass(prhs[3], "double")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notBinary", "Input parameter 'use inVp' must be 0 or 1.");
            return;
        }
        /* get parameter */
        iUseInVp = (int)mxGetScalar(prhs[3]);
        /* check parameter */
        if ((iUseInVp < 0) || (iUseInVp > 1)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notBinary", "Input parameter 'use inVp' must be 0 or 1.");
            return;
        }
    }

    dNodeCoordinateOffset = 0;
    /* check fifth argument */
    if (nrhs >= 5) {
        /* check type of fifth input argument */
        if (!mxIsClass(prhs[4], "double")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notDouble", "Input parameter 'nodeCoordinateOffset' must be a double value.");
            return;
        }
        /* get parameter */
        dNodeCoordinateOffset = (double)mxGetScalar(prhs[4]);
    }

    iListComments = 0;
    /* check sixth argument */
    if (nrhs >= 6) {
        /* check type of third input argument */
        if (!mxIsClass(prhs[5], "double")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notBinary", "Input parameter 'listComments' must be 0 or 1.");
            return;
        }
        /* get parameter */
        iListComments = (int)mxGetScalar(prhs[5]);
        /* check parameter */
        if ((iListComments < 0) || (iListComments > 1)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notBinary", "Input parameter 'listComments' must be 0 or 1.");
            return;
        }
        /* "list comments" mode is not available on linux and Apple Mac OS */
        #if defined(__linux__) || defined(__APPLE__)
            if (iListComments > 0) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:notAvailable", "Comment listing (input parameter 'listComments') is not available on linux and Apple operating systems.");
                return;
            }
        #endif
    }

    iSelectMode = 0;
    /* check 7th argument */
    if (nrhs >= 7) {
        /* check type of third input argument */
        if (!mxIsClass(prhs[6], "double")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notBinary", "Input parameter 'selectMode' must be 0, 1, 2 or 3.");
            return;
        }
        /* get parameter */
        iSelectMode = (int)mxGetScalar(prhs[6]);
        /* check parameter */
        if ((iSelectMode < 0) || (iSelectMode > 3)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notBinary", "Input parameter 'selectMode' must be 0, 1, 2 or 3.");
            return;
        }
        /* select mode is not available on linux */
        #if defined(__linux__) || defined(__APPLE__)
            if (iSelectMode > 0) {
                mexErrMsgIdAndTxt("Braintracing:parseNML:notAvailable", "Select mode is not available on linux and Apple operating systems.");
                return;
            }
        #endif
    }
    /* set iKeepNodeAsStruct to zero if select mode is active */
    if (iSelectMode > 0) {
        iKeepNodeAsStruct = 0;
    }
    /* check requirements for select mode */
    if (iListComments && iSelectMode) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:notAvailable", "List comments and select mode cannot be combined.");
        return;
    }
    if (iSelectMode && (nrhs < (7 + 2))) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:notAvailable", "Select mode requires two additional parameters for lower and upper border.");
        return;
    }
    /* check 8th and 9th argument */
    if (nrhs >= 9) {
        /* check type of third input argument */
        if ((!mxIsClass(prhs[7], "double")) || (!mxIsClass(prhs[8], "double"))) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notBinary", "Input parameter 'selectModeMin' and 'selectModeMax' must be a double value.");
            return;
        }
        /* get parameter */
        switch (iSelectMode) {
            case 1:
                    dSelectMinX = (double)mxGetScalar(prhs[7]);
                    dSelectMaxX = (double)mxGetScalar(prhs[8]);
                    break;
            case 2:
                    dSelectMinY = (double)mxGetScalar(prhs[7]);
                    dSelectMaxY = (double)mxGetScalar(prhs[8]);
                    break;
            case 3:
                    dSelectMinZ = (double)mxGetScalar(prhs[7]);
                    dSelectMaxZ = (double)mxGetScalar(prhs[8]);
                    break;
        }
    }
    /* check 10th argument */
    /* copy default output filename into variable */
    strcpy(szPathAndFilenameOutput, FILENAME_OUTPUT_SELECT_MODE);
    if (nrhs >= 10) {
        /* check type of input argument */
        if( !mxIsClass(prhs[9], "char")) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:notString", "Input parameter 'filenameOutput' must be a string.");
            return;
        }

        /* get file name */
        if (mxGetString(prhs[9], szPathAndFilenameOutput, MAX_LENGTH_FILENAME + MAX_LENGTH_PATH)) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:FilenameTooLong", "Input parameter 'filenameOutput' too long.");
            return;
        }
    }

    /* check number of output arguments */
    if ((nlhs != 1) && (iListComments == 0) && (iSelectMode == 0)) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:nlhs", "Output required. Proper use of function is 'MyVar = parseNML filename'. You can also add the following (optional) parameters: "
                          "MyVar = parseNML(fileName[character], keepNodeAsStruct[0/1], nodesAsStruct is cell[0/1], use inVp[0/1], "
                          "nodeCoordinateOffset[double], listComments[0/1]) For webKnossos use 'MyVar = parseNML(filename,1,1,1,1)'");
        return;
    }
    if ((nlhs != 0) && (iListComments == 1)) {
        mexErrMsgIdAndTxt("Braintracing:parseNML:nlhs", "No output allowed. Proper use of function for listing comments is "
                          "'parseNML(fileName[character], keepNodeAsStruct[0/1], nodesAsStruct is cell[0/1], use inVp[0/1], "
                          "nodeCoordinateOffset[double], listComments[1])'. For webKnossos use 'parseNML(filename,1,1,1,1,1)'.");
        return;
    }

    /* start time */
    time_start = time(NULL);

    /* initialize global variables */
    iNumberOfNodes = 0;
    iNumberOfEdges = 0;
    iNumberOfEdgesOffset = 0;
    nmlThingCounterOffset = 0;
    nmlThingCounterAllFiles = 0;
    iParameterDone = 0;
    iGlobalNodeId = 1; /* only used in selection mode (id of first node: 1) */
    bNodeIdConversionFastMode = 1; /* node id conversion in fast mode by default */

    /* check which attributes are coordinates and which are active */
    for (LOOP_VAR i = 0; i < NUM_OF_NODE_ATTRIBUTES_ALL; ++i) {
        /* check for coordinate */
        if ((strcmp(nmlNodeAttributes[i], "x") == 0) || (strcmp(nmlNodeAttributes[i], "y") == 0) ||
            (strcmp(nmlNodeAttributes[i], "z") == 0) ||
            (strcmp(nmlNodeAttributes[i], "X") == 0) || (strcmp(nmlNodeAttributes[i], "Y") == 0) ||
            (strcmp(nmlNodeAttributes[i], "Z") == 0)) {
            iIsCoordinate[i] = 1;
        } else {
            iIsCoordinate[i] = 0;
        }
        /* check if attribute is active */
        iIsActive[i] = 1; /* default attribute is active */
        if (!iUseInVp) {
            if ((strcmp(nmlNodeAttributes[i], "inVp") == 0) || (strcmp(nmlNodeAttributes[i], "inMag") == 0) ||
                (strcmp(nmlNodeAttributes[i], "rotX") == 0) || (strcmp(nmlNodeAttributes[i], "rotY") == 0) ||
                (strcmp(nmlNodeAttributes[i], "rotZ") == 0) || (strcmp(nmlNodeAttributes[i], "bitDepth") == 0) ||
                (strcmp(nmlNodeAttributes[i], "interpolation") == 0) || (strcmp(nmlNodeAttributes[i], "withSpeed") == 0) ||
                (strcmp(nmlNodeAttributes[i], "time") == 0)) {
                iIsActive[i] = 0;
            }
        }
    }

    /* get file list for list comments function */
    if ((iListComments != 0) || (iSelectMode != 0)) {
        /* show message */
        if (iListComments != 0) {
            printf("COMMENT LIST MODE\n");
        }
        if (iSelectMode != 0) {
            printf("SELECT MODE\n");
            if (nlhs == 0) {
                /* create file */
                if (!(fileOutput = fopen (szPathAndFilenameOutput, "w"))) {
                    sprintf(szMessageBuffer, "Cannot create file %s.\n", szPathAndFilenameOutput);
                    mexErrMsgIdAndTxt("Braintracing:parseNML:CreateFile", szMessageBuffer);
                    return;
                }
                fprintf(fileOutput, "<things>\n");
            }
        }
        /* add .nml file extension */
        if (strlen(szPathAndFilename) == 0) {
            strcpy(szPathCommentFiles, "*.nml");
        } else {
            if ((szPathAndFilename[strlen(szPathAndFilename) - 1] != '\\') && (szPathAndFilename[strlen(szPathAndFilename) - 1] != '/')) {
                sprintf(szPathCommentFiles, "%s\\*.nml", szPathAndFilename); /* add slash and extension */
            } else {
                sprintf(szPathCommentFiles, "%s*.nml", szPathAndFilename);
            }
        }
        #if !defined(__linux__) && !defined(__APPLE__)
            /* list files */
            fileHandle = FindFirstFile(szPathCommentFiles, &windowsFindData);
            /* check if next file is identical with output file */
            if ((iListComments != 0) || (iSelectMode != 0)) {
                if (!(windowsFindData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
                {
                    /* check length of filename */
                    if (strlen(windowsFindData.cFileName) > MAX_LENGTH_FILENAME) {
                        FindClose(fileHandle);
                        mexErrMsgIdAndTxt("Braintracing:parseNML:FilenameTooLong", "Filename too long. Increasing MAX_LENGTH_FILENAME in the source code might help.");
                        return;
                    }
                    /* copy filename */
                    if ((szPathAndFilename[strlen(szPathAndFilename) - 1] != '\\') && (szPathAndFilename[strlen(szPathAndFilename) - 1] != '/')) {
                        sprintf(szPathAndFilenameCommentFiles, "%s\\%s", szPathAndFilename, windowsFindData.cFileName); /* add slash and extension */
                    } else {
                        sprintf(szPathAndFilenameCommentFiles, "%s%s", szPathAndFilename, windowsFindData.cFileName);
                    }
                    /* compare filenames */
                    if (stricmp(szPathAndFilenameCommentFiles, szPathAndFilenameOutput) == 0) {
                        /* skip file and get the next one */
                        iNextFileSelectMode = FindNextFile(fileHandle, &windowsFindData);
                    }
                }
            }
        #endif
    }

    /* process nml files */
    do {
        nmlThingCounter = 0;
        bNoOptionalArgumentsFound = 0;
        do {
            /* in file write mode also reset thing counter */
            if ((iSelectMode != 0) && (nlhs == 0)) {
                iNumberOfNodes = 0;
                iNumberOfEdges = 0;
                iNumberOfEdgesOffset = 0;
                nmlThingCounterOffset = 0;
                nmlThingCounter = 0;
            }
            #if !defined(__linux__) && !defined(__APPLE__)
                if ((iListComments != 0) || (iSelectMode != 0)) {
                    if (!(windowsFindData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
                    {
                        /* check length of filename */
                        if (strlen(windowsFindData.cFileName) > MAX_LENGTH_FILENAME) {
                            FindClose(fileHandle);
                            mexErrMsgIdAndTxt("Braintracing:parseNML:FilenameTooLong", "Filename too long. Increasing MAX_LENGTH_FILENAME in the source code might help.");
                            return;
                        }
                        /* copy filename */
                        if ((szPathAndFilename[strlen(szPathAndFilename) - 1] != '\\') && (szPathAndFilename[strlen(szPathAndFilename) - 1] != '/')) {
                            sprintf(szPathAndFilenameCommentFiles, "%s\\%s", szPathAndFilename, windowsFindData.cFileName); /* add slash and extension */
                        } else {
                            sprintf(szPathAndFilenameCommentFiles, "%s%s", szPathAndFilename, windowsFindData.cFileName);
                        }
                        /* increase file counter */
                        ++iFileCounter;
                        /* print file name */
                        if (iSelectMode != 0) {
                            if (nmlThingCounterAllFiles == 0) {
                                printf ("\n");
                            }
                            printf ("%s\n", windowsFindData.cFileName);
                        }
                        /* get task id from filename */
                        szTaskId[0] = 0; /* reset task id => if task id cannot identified the variable will be empty */
                        if (iListComments != 0) {
                            iCountCharacters = 0;
                            for (LOOP_VAR i = ((int)strlen(szPathAndFilenameCommentFiles) - 1); i >= 0; --i) {
                                c = szPathAndFilenameCommentFiles[i];
                                if (((c >= '0') && (c <= '9')) || ((c >= 'a') && (c <= 'f')) || ((c >= 'A') && (c <= 'F'))) {
                                    ++iCountCharacters;
                                } else {
                                    /* check if id was found */
                                    if (iCountCharacters == LENGTH_MONGODB_ID) {
                                        break;
                                    } else {
                                        /* reset character counter */
                                        iCountCharacters = 0;
                                    }
                                }
                            }
                            /* check if task id was found */
                            if (iCountCharacters == LENGTH_MONGODB_ID) {
                                strncpy(szTaskId, &szPathAndFilenameCommentFiles[i + 1], LENGTH_MONGODB_ID); /* copy task id */
                                szTaskId[LENGTH_MONGODB_ID] = 0; /* mark end of the string */
                            }
                        }
                    }
                }
            #endif

            /* open file */
            if ((iListComments == 0) && (iSelectMode == 0)) {
                if (!(file = fopen (szPathAndFilename, "r"))) {
                    sprintf(szMessageBuffer, "Cannot open file %s.\n", szPathAndFilename);
                    mexErrMsgIdAndTxt("Braintracing:parseNML:OpenFile", szMessageBuffer);
                    return;
                }
            } else {
                if (!(file = fopen (szPathAndFilenameCommentFiles, "r"))) {
                    sprintf(szMessageBuffer, "Cannot open file %s.\n", szPathAndFilenameCommentFiles);
                    mexErrMsgIdAndTxt("Braintracing:parseNML:OpenFile", szMessageBuffer);
                    return;
                }
            }

            /* ************** */
            /* parse nml file */
            /* ***************/


            /* initialize global variables */
            if ((iSelectMode == 0) || (nlhs == 0)) {
                /* in normal mode or file write select mode (without output) reset number of nodes and edges */
                iNumberOfNodes = 0;
                iNumberOfEdges = 0;
            }
            iNumberOfBranchpoints = 0;
            gLineCounter = 0;

            /* initialize local variables */
            bCommentsAvailable = false;

            /* initialize dimensions */
            iDimensions[0] = 1;

            /* initialize node ID conversion and node thing id */
            for (LOOP_VAR i = 0; i < MAX_NUMBER_OF_NODES; i++) {
                iNodeIdConversion[i] = 0;
                iNodeIdConversionAllThings[i] = -1;
                pNodeComment[i] = NULL;
            }
            /* these two variables comprise (MAX_NUMBER_OF_NODES + 1) values therefore also the index MAX_NUMBER_OF_NODES has to be initialized */
            iNodeIdConversion[MAX_NUMBER_OF_NODES] = 0;
            iNodeIdConversionAllThings[MAX_NUMBER_OF_NODES] = -1;

            /* reset memory pointers and counters */
            gMemorypointer = 0;
            gMemorypointerCurrent = 0;
            nmlElementCounter = 0;
            nmlAttributeCounter = 0;
            nmlParameterCounter = 0;
            nmlCommentCounter = 0;

            /* things */
            readNmlElement(file);
            if (strcmp(szNmlElement, "things")) {
                sprintf(szMessageBuffer, "Expected element things. Got %s.\n", szNmlElement);
                mexErrMsgIdAndTxt("Braintracing:parseNML:things", szMessageBuffer);
                return;
            }

            /* reset memory pointer */
            gMemorypointer = gMemorypointerCurrent;

            /* oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo*/ 
            /* oooooooo    read all elements until end (= "/things")      ooooooooooooo */
            /* oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo*/
            do {
                /* reset counters*/
                nmlElementCounter = 0;
                nmlAttributeCounter = 0;

                /* save memory pointer (last position) */
                gMemorypointerCurrent = gMemorypointer;

                /* read element */
                readNmlElement(file);

                /* ignore empty elements */
                if ((strcmp(szNmlElement, "parameters/") == 0) || (strcmp(szNmlElement, "comments/") == 0) || (strcmp(szNmlElement, "branchpoints/") == 0) ||
                    (strcmp(szNmlElement, "thing/") == 0)) {
                    /* reset memory pointer */
                    gMemorypointer = gMemorypointerCurrent;
                    continue;
                }
                
                /* read comments */
                if (strcmp(szNmlElement, "comments") == 0) {
                    /* reset element and attribute counters */
                    nmlElementCounter = 0;
                    nmlAttributeCounter = 0;

                    bCommentsAvailable = true;

                    /* reset memory pointer */
                    gMemorypointer = gMemorypointerCurrent;

                    do {
                        /* reset attribute counter */
                        nmlAttributeCounter = 0;
                        /* save memory pointer (last position) */
                        gMemorypointerCurrent = gMemorypointer;

                        /* read element */
                        if (readNmlElement(file)) {
                            /* stop program after error */
                            fclose (file);
                            if (iListComments == 0) {
                                plhs[0] = mxCreateCellMatrix (1, 1);
                            }
                            return;
                        }

                        /* ignore end of comment elements) */
                        if (strcmp(szNmlElement, "/comment") == 0) {
                            /* reset memory pointer */
                            gMemorypointer = gMemorypointerCurrent;
                            continue;
                        }

                        /* check element */
                        if ((strcmp(szNmlElement, "comment") != 0) && (strcmp(szNmlElement, "comment/") != 0)  && (strcmp(szNmlElement, "/comments") != 0)) {
                            sprintf(szMessageBuffer, "Illegal element %s in comment line %ld.", szNmlElement, (nmlCommentCounter + 1));
                            mexErrMsgIdAndTxt("Braintracing:parseNML:comment", szMessageBuffer);
                            return;
                        }

                        if (((strcmp(szNmlElement, "comment") == 0) || (strcmp(szNmlElement, "comment/") == 0)) && (iSelectMode == 0)) {
                            /* check node counter */
                            if (nmlCommentCounter >= MAX_NUMBER_OF_COMMENTS) {
                                mexErrMsgIdAndTxt("Braintracing:parseNML:comment", "Too many comments in nml file. Increasing MAX_NUMBER_OF_COMMENTS could help.");
                                return;
                            }

                            /* get comment attributes (id and content) */
                            if (getIntegerAttribute ("node", &i, true)) {
                                /* stop program after error */
                                fclose (file);
                                if (iListComments == 0) {
                                    plhs[0] = mxCreateCellMatrix (1, 1);
                                }
                                return;
                            }
                            /* check node id value */
                            if ((i <= 0) || ((i > MAX_NUMBER_OF_NODES) && (bNodeIdConversionFastMode == 1))) {
                                sprintf(szMessageBuffer, "Illegal node id %d in comment line %ld. Must be >= 1 and <= %d.\n",
                                        i, (nmlCommentCounter + 1), MAX_NUMBER_OF_NODES);
                                mexErrMsgIdAndTxt("Braintracing:parseNML:comment", szMessageBuffer);
                                return;
                            }
                            /* store integer value of id in memory */
                            iCommentNodeID[nmlCommentCounter] = i;

                            /* get comment content */
                            if (getStringAttribute ("content", &p, true)) {
                                /* stop program after error */
                                fclose (file);
                                if (iListComments == 0) {
                                    plhs[0] = mxCreateCellMatrix (1, 1);
                                }
                                return;
                            }
                            /* store comment in memory */
                            pCommentContent[nmlCommentCounter] = p;
                            /* if node exists also connect comment to the corresponding node otherwise print warning */
                            if (bNodeIdConversionFastMode == 1) {
                                if (iNodeIdConversionAllThings[i] >= 0) {
                                    pNodeComment[iNodeIdConversionAllThings[i]] = p;
                                } else {
                                    printf("WARNING: Comment '%s' refers to nonexistent node ID %d. Comment will be ignored.\n", p, i);
                                }
                            } else {
                                /* search for node */
                                bNodeFound = 0;
                                j = 0;
                                d = (double)i;
                                while (j < iNumberOfNodes) {
                                    if (dNode[j][0] == d) {
                                        bNodeFound = 1;
                                        break; /* exit while loop */
                                    }
                                    ++j;
                                }
                                if (bNodeFound == 1) {
                                    pNodeComment[j] = p;
                                } else {
                                    printf("WARNING: Comment '%s' refers to nonexistent node ID %d. Comment will be ignored.\n", p, i);
                                }
                            }

                            /* increase comment counter */
                            nmlCommentCounter++;
                        }

                    } while (strcmp(szNmlElement, "/comments"));

                    /* reset memory pointer */
                    gMemorypointer = gMemorypointerCurrent;

                    continue;
                }

                /* read parameters */
                if (strcmp(szNmlElement, "parameters") == 0) {
                    /* decrease element counter by 1 (because "parameters" is supposed to have no attributes and therefore the element itself is not needed) */
                    nmlElementCounter--;
                    /* save element counter */
                    nmlElementCounterCurrent = nmlElementCounter;
                    /* read parameters */
                    nmlParameterCounter = 0;
                    if (!statusElementClosed) {
                        do {
                            readNmlElement(file);
                            if (szNmlElement[0] != '/') {
                                if (nmlParameterCounter >= MAX_NUMBER_OF_PARAMETERS) {
                                    mexErrMsgIdAndTxt("Braintracing:parseNML:parameters", "Too many parameters in nml file. "
                                                      "Increasing MAX_NUMBER_OF_PARAMETERS could help.");
                                    return;
                                }
                                if (nmlElementCounter <= 0) {
                                    mexErrMsgIdAndTxt("Braintracing:parseNML:parameters", "Internal error. No parameter section found.");
                                    return;
                                }
                                pParameterName[nmlParameterCounter] = pElementList[nmlElementCounter - 1];
                                nmlParameterCounter++;
                            } else {
                                /* decrease element counter by 1 (because /parameters is no element) */
                                nmlElementCounter--;
                            }
                        } while ((szNmlElement[0] != '/') || (strcmp(szNmlElement, "/parameters"))); /* two comparisons fastens loop: check for /parameters only if first character is / */
                    }
                    /* read parameters into struct */
                    nmlAttributeCounter = 0;
                    for (LOOP_VAR i = 0; i < nmlParameterCounter; i++) {
                        iNumberOfParameterAttributes[i] = iNumberOfAttributes[nmlElementCounterCurrent + i];
                        for (LOOP_VAR j = 0; j < iNumberOfAttributes[nmlElementCounterCurrent + i]; j++) {
                            if (nmlAttributeCounter >= MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL) {
                                mexErrMsgIdAndTxt("Braintracing:parseNML:parameters", "Too many parameter attributes in nml file. "
                                                  "Increasing MAX_NUMBER_OF_PARAMETER_ATTRIBUTES_TOTAL could help.");
                                return;
                            }
                            pParameterAttributeName[nmlAttributeCounter] = pAttributeName[nmlAttributeCounter];
                            pParameterAttributeValue[nmlAttributeCounter] = pAttributeValue[nmlAttributeCounter];
                            nmlAttributeCounter++;
                        }
                    }
                    /* DO NOT RESET MEMORY POINTER HERE !!!  DATA WILL BE USED LATER !!!  (FORBIDDEN:  gMemorypointer = gMemorypointerCurrent;) */
                    continue;
                }

                /* *************************** */
                /* ****   thing (=tree)   **** */
                /* *************************** */
                if (strcmp(szNmlElement, "thing") == 0) { 

                    /* get thing id */
                    if (getDoubleAttribute("id", &d, &p, true, false, false)) {
                        /* stop program after error */
                        fclose (file);
                        if (iListComments == 0) {
                            plhs[0] = mxCreateCellMatrix (1, 1);
                        }
                        return;
                    }
                    /* store thing id */
                    if (nmlThingCounter >= MAX_NUMBER_OF_THINGS) {
                        mexErrMsgIdAndTxt("Braintracing:parseNML:thing", "Too many things in nml file. Increasing MAX_NUMBER_OF_THINGS could help.");
                        return;
                    }
                    dThingID[nmlThingCounter] = d;

                    /* get thing name */
                    if (getStringAttribute("name", &p, false)) {
                        pThingName[nmlThingCounter] = NULL;
                        /* no error message because older .nml files don't support thing names */
                    }
                    pThingName[nmlThingCounter] = p;

                    /* reset number of nodes and edges */
                    iNumberOfNodesThing[nmlThingCounter] = 0;
                    iNumberOfEdgesThing[nmlThingCounter] = 0;

                    /* reset element and attribute counters */
                    nmlElementCounter = 0;
                    nmlAttributeCounter = 0;

                    do {
                        /* reset attribute counter */
                        nmlAttributeCounter = 0;
                        /* save memory pointer (last position) */
                        gMemorypointerCurrent = gMemorypointer;

                        /* read element */
                        if (readNmlElement(file)) {
                            /* stop program after error */
                            fclose (file);
                            if (iListComments == 0) {
                                plhs[0] = mxCreateCellMatrix (1, 1);
                            }
                            return;
                        }

                        /* ignore empty elements <nodes/> and <edges/> (there should be no empty elements anyway) */
                        if ((strcmp(szNmlElement, "nodes/") == 0) || (strcmp(szNmlElement, "edges/") == 0)) {
                            /* reset memory pointer */
                            gMemorypointer = gMemorypointerCurrent;
                            continue;
                        }

                        /* ignore element nodes and edges (just for comfort; strictly speaking you had to check that nodes contains only node and edges only edge) */
                        if ((strcmp(szNmlElement, "nodes") == 0) || (strcmp(szNmlElement, "/nodes") == 0) ||
                            (strcmp(szNmlElement, "edges") == 0) || (strcmp(szNmlElement, "/edges") == 0)) {
                            /* reset memory pointer */
                            gMemorypointer = gMemorypointerCurrent;
                            continue;
                        }

                        /* ignore closing elements </nodes> and </edges> */
                        if ((strcmp(szNmlElement, "/nodes") == 0) || (strcmp(szNmlElement, "/edges") == 0)) {
                            /* reset memory pointer */
                            gMemorypointer = gMemorypointerCurrent;
                            continue;
                        }

                        /* +++++++++++++++++++++ */
                        /* ++++  read node  ++++ */
                        /* +++++++++++++++++++++ */
                        if ((strcmp(szNmlElement, "node") == 0) || (strcmp(szNmlElement, "node/") == 0)) {
                            /* check node counter */
                            if (iNumberOfNodes >= MAX_NUMBER_OF_NODES) {
                                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Too many nodes in nml file. Increasing MAX_NUMBER_OF_NODES could help.\n");
                                return;
                            }

                            /* get node attributes */
                            for (LOOP_VAR i = 0; i < NUM_OF_NODE_ATTRIBUTES_ALL; ++i) {
                                /* comment attribute not available */
                                if (strcmp(nmlNodeAttributes[i], "comment") == 0) {
                                    continue;
                                }
                                /* check size */
                                if (i >= NUM_OF_NODE_ATTRIBUTES_NML_FILE) {
                                    continue;
                                }
                                /* ignore inactive attributes */
                                if (!iIsActive[i]) {
                                    continue;
                                }
                                /* if no optional arguments are available (detected by previous call) ignore all otional values => increases performance */
                                if (nmlNodeAttributesOptional[i] && bNoOptionalArgumentsFound)
                                {
                                    p = 0;
                                    d = 0;
                                }
                                else
                                {
                                    /* get attribute */
                                    if (getDoubleAttribute (nmlNodeAttributes[i], &d, &p, true, nmlNodeAttributesOptional[i], nmlNodeAttributesOptional[i])) {
                                        /* if attribute is optional continue */
                                        if (nmlNodeAttributesOptional[i])
                                        {
                                            p = 0;
                                            d = 0;
                                            bNoOptionalArgumentsFound = 1;
                                        }
                                        else
                                        {
                                            /* stop program after error */
                                            fclose (file);
                                            if (iListComments == 0) {
                                                plhs[0] = mxCreateCellMatrix (1, 1);
                                            }
                                            return;
                                        }
                                    }
                                }
                                /* correct coordinate offset */
                                if ((dNodeCoordinateOffset != 0) && (iIsCoordinate[i])) {
                                    d += dNodeCoordinateOffset;
                                }
                                /* store double value and pointer of attribute in memory */
                                dNode[iNumberOfNodes][i] = d;
                                pNode[iNumberOfNodes][i] = p;
                                /* calculate node ID conversion (id = attribute index 0) - not in select mode */
                                if ((i == 0) && (bNodeIdConversionFastMode == 1)) {
                                    /* check id */
                                    if (dNode[iNumberOfNodes][0] >= MAX_NUMBER_OF_NODES) {
                                        bNodeIdConversionFastMode = 0;
                                        /* print warning */
                                        printf("WARNING: Node ID %d is too big for fast mode. parseNml will switch to slow mode.\n", (int)dNode[iNumberOfNodes][0]);
                                        /* sprintf(szMessageBuffer, "Node ID %d too big. Increasing MAX_NUMBER_OF_NODES could help.",
                                                   (int)dNode[iNumberOfNodes][0]);
                                           mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", szMessageBuffer);
                                           return;
                                        */
                                    } else iNodeIdConversionAllThings[(int)d] = iNumberOfNodes;
                                }
                            }

                            /* check select mode boundaries */
                            if (iSelectMode == 0) {
                                /* increase node counter */
                                iNumberOfNodes++;
                                iNumberOfNodesThing[nmlThingCounter]++;
                            } else {
                                iNodeInSelectedArea = 0;
                                switch (iSelectMode) {
                                    case 1: if ((dNode[iNumberOfNodes][2] >= dSelectMinX) && (dNode[iNumberOfNodes][2] <= dSelectMaxX)) iNodeInSelectedArea = 1; break;
                                    case 2: if ((dNode[iNumberOfNodes][3] >= dSelectMinY) && (dNode[iNumberOfNodes][3] <= dSelectMaxY)) iNodeInSelectedArea = 1; break;
                                    case 3: if ((dNode[iNumberOfNodes][4] >= dSelectMinZ) && (dNode[iNumberOfNodes][4] <= dSelectMaxZ)) iNodeInSelectedArea = 1; break;
                                }
                                if (iNodeInSelectedArea > 0) {
                                    /* print node */
                                    printf("%ld/%ld/%ld\n", (long int)dNode[iNumberOfNodes][2], (long int)dNode[iNumberOfNodes][3], (long int)dNode[iNumberOfNodes][4]);
                                    /* increase node counter */
                                    iNumberOfNodes++;
                                    iNumberOfNodesThing[nmlThingCounter]++;
                                }
                            }

                            /* DO NOT RESET MEMORY POINTER HERE !!!  DATA WILL BE USED LATER !!!  (FORBIDDEN:  gMemorypointer = gMemorypointerCurrent;) */
                            continue;
                        }

                        /* +++++++++++++++++++++ */
                        /* ++++  read edge  ++++ */
                        /* +++++++++++++++++++++ */
                        if ((strcmp(szNmlElement, "edge") == 0) || (strcmp(szNmlElement, "edge/") == 0)) {
                            /* check edge counter */
                            if (iNumberOfEdges >= MAX_NUMBER_OF_EDGES) {
                                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Too many edges in nml file. Increasing MAX_NUMBER_OF_EDGES could help.\n");
                                return;
                            }

                            /* get edge attributes (source and target) */
                            iIllegalEdge = 0;
                            for (LOOP_VAR i = 0; i < NUM_OF_EDGE_ATTRIBUTES; i++) {
                                /* get attribute */
                                if (getIntegerAttribute (nmlEdgeAttributes[i], &j, true)) {
                                    /* stop program after error */
                                    fclose (file);
                                    if (iListComments == 0) {
                                        plhs[0] = mxCreateCellMatrix (1, 1);
                                    }
                                    return;
                                }
                                /* check edge value */
                                if ((j <= 0) || ((j > MAX_NUMBER_OF_NODES) && (bNodeIdConversionFastMode == 1))) {
                                    if (iSelectMode != 0) {
                                        printf("WARNING: Illegal edge source or target %d in edge line %d. Must be >= 1 and <= %d.\n", j, (iNumberOfEdges + 1), MAX_NUMBER_OF_NODES);
                                        /* allow node/edge 0 in selection mode (only ignore edges with a source or target larger than the maximum number of nodes) */
                                        if (j > MAX_NUMBER_OF_NODES) {
                                            iIllegalEdge = 1;
                                            continue;
                                        }
                                    } else {
                                        iIllegalEdge = 1;
                                        sprintf(szMessageBuffer, "Illegal edge source or target %d in edge line %d. Must be >= 1 and <= %d.\n",
                                                j, (iNumberOfEdges + 1), MAX_NUMBER_OF_NODES);
                                        mexErrMsgIdAndTxt("Braintracing:parseNML:edge", szMessageBuffer);
                                        return;
                                    }
                                }
                                /* store integer value of attribute in memory */
                                iEdge[iNumberOfEdges][i] = j;
                            }
                            
                            if (iSelectMode == 0) {
                                /* increase edge counter */
                                iNumberOfEdges++;
                                iNumberOfEdgesThing[nmlThingCounter]++;
                            } else {
                                /* check if node exists */
                                iNodeIdFoundSource = 0;
                                iNodeIdFoundTarget = 0;
                                if (iIllegalEdge == 0) {
                                    for (LOOP_VAR m = iNumberOfNodes - iNumberOfNodesThing[nmlThingCounter]; m < iNumberOfNodes; ++m) {
                                        if ((int)dNode[m][0] == iEdge[iNumberOfEdges][0]) {
                                            iNodeIdFoundSource = 1;
                                        }
                                        if ((int)dNode[m][0] == iEdge[iNumberOfEdges][1]) {
                                            iNodeIdFoundTarget = 1;
                                        }
                                    }
                                    if ((iNodeIdFoundSource != 0) && (iNodeIdFoundTarget != 0)) {
                                        /* increase edge counter */
                                        iNumberOfEdges++;
                                        iNumberOfEdgesThing[nmlThingCounter]++;
                                    }
                                }
                            }

                            /* reset memory pointer (for saving memory space) because no further "edge" data except source and target is needed */
                            gMemorypointer = gMemorypointerCurrent;
                            continue;
                        }

                    } while (strcmp(szNmlElement, "/thing"));

                    /* increase thing counter */
                    nmlThingCounter++;
                    nmlThingCounterAllFiles++;

                }

                /* *********************************** */
                /* ****      branchpoints         **** */
                /* *********************************** */
                if (strcmp(szNmlElement, "branchpoints") == 0) {
                    /* read branchpoints */
                    do {
                        /* reset attribute counter */
                        nmlAttributeCounter = 0;
                        /* save memory pointer (last position) */
                        gMemorypointerCurrent = gMemorypointer;

                        /* read element */
                        if (readNmlElement(file)) {
                            /* stop program after error */
                            fclose (file);
                            if (iListComments == 0) {
                                plhs[0] = mxCreateCellMatrix (1, 1);
                            }
                            return;
                        }

                        /* ++++++++++++++++++++++++++++ */
                        /* ++++  read branchpoint  ++++ */
                        /* ++++++++++++++++++++++++++++ */
                        if ((strcmp(szNmlElement, "branchpoint") == 0) || (strcmp(szNmlElement, "branchpoint/") == 0)) {
                            /* check branchpoint counter */
                            if (iNumberOfBranchpoints >= MAX_NUMBER_OF_BRANCHPOINTS) {
                                fclose (file);
                                mexErrMsgIdAndTxt("Braintracing:parseNML:readNmlElement", "Too many branchpoints in nml file. "
                                                  "Increasing MAX_NUMBER_OF_BRANCHPOINTS could help.");
                                if (iListComments == 0) {
                                    plhs[0] = mxCreateCellMatrix (1, 1);
                                }
                                return;
                            }

                            /* get branchpoint attribute (id) */
                            if (getIntegerAttribute (nmlBranchpointAttributes[0], &j, true)) {
                                /* stop program after error */
                                fclose (file);
                                if (iListComments == 0) {
                                    plhs[0] = mxCreateCellMatrix (1, 1);
                                }
                                return;
                            }
                            /* check branchpoint value */
                            if ((j <= 0) || ((j > MAX_NUMBER_OF_NODES) && (bNodeIdConversionFastMode == 1))) {
                                fclose (file);
                                sprintf(szMessageBuffer, "Illegal branchpoint id %d in branchpoint line %d. Must be >= 1 and <= %d.",
                                        j, (iNumberOfBranchpoints + 1), MAX_NUMBER_OF_NODES);
                                mexErrMsgIdAndTxt("Braintracing:parseNML:branchpoint", szMessageBuffer);
                                if (iListComments == 0) {
                                    plhs[0] = mxCreateCellMatrix (1, 1);
                                }
                                return;
                            }

                            if (iSelectMode == 0) {
                                /* store integer value of attribute in memory */
                                iBranchpoint[iNumberOfBranchpoints] = j;
                                /* increase branchpoint counter */
                                iNumberOfBranchpoints++;
                            }

                            /* reset memory pointer */
                            gMemorypointer = gMemorypointerCurrent;
                            continue;
                        }
                    } while (strcmp(szNmlElement, "/branchpoints"));
                }

            } while (strcmp(szNmlElement, "/things"));

            /* close file */
            fclose (file);

            if (iSelectMode == 0) {
                /* in default mode only one file is processed */
                iNextFileSelectMode = 0;
            } else {
                /* write data to file */
                if (nlhs == 0) {
                    /* renumber nodes */
                    iNumberOfNodesOffset = 0;
                    iNumberOfEdgesOffset = 0;
                    nmlAttributeCounter = 0;
                    for (LOOP_VAR k = 0; k < nmlThingCounter; k++) {
                        /* remeber node id */
                        iGlobalNodeIdStart = iGlobalNodeId;
                        /* renumber nodes */
                        for (LOOP_VAR i = 0; i < iNumberOfNodesThing[k]; i++) {
                            /* first step: check if node does NOT have to be renumbered (this is the case */
                            /*   if either it IS exactly identical to the assigned global id or WAS exactly identical in a previous round of the loop) */
                            if (((int)dNode[iNumberOfNodesOffset + i][0] >= iGlobalNodeIdStart) && ((int)dNode[iNumberOfNodesOffset + i][0] <= iGlobalNodeId)) {
                                if ((int)dNode[iNumberOfNodesOffset + i][0] == iGlobalNodeId) {
                                    iGlobalNodeId++;
                                }
                                continue;
                            }
                            /* second step: check if current global node id already exists in the node set */
                            /* if yes increase global node id */
                            do {
                                iNodeExists = 0;
                                for (LOOP_VAR j = i + 1; j < iNumberOfNodesThing[k]; j++) {
                                    if ((int)dNode[iNumberOfNodesOffset + j][0] == iGlobalNodeId) {
                                        iNodeExists = 1;
                                        iGlobalNodeId++;
                                        break;
                                    }
                                }
                            } while (iNodeExists > 0);
                            /* renumber node */
                            iNodeIdOriginal = (int)dNode[iNumberOfNodesOffset + i][0];
                            dNode[iNumberOfNodesOffset + i][0] = (double)iGlobalNodeId;
                            /* renumber corresponding edge */
                            for (LOOP_VAR j = 0; j < iNumberOfEdgesThing[k]; j++) {
                                for (LOOP_VAR m = 0; m < NUM_OF_EDGE_ATTRIBUTES; m++) {
                                    if (iEdge[iNumberOfEdgesOffset + j][m] == iNodeIdOriginal) {
                                        iEdge[iNumberOfEdgesOffset + j][m] = iGlobalNodeId;
                                    }
                                }
                            }
                            /* increase node id */
                            iGlobalNodeId++;
                        }
                        /* calculate nodes offset and edges offset */
                        iNumberOfNodesOffset += iNumberOfNodesThing[k];
                        iNumberOfEdgesOffset += iNumberOfEdgesThing[k];
                    }
                    /* write data */
                    iNumberOfNodesOffset = 0;
                    iNumberOfEdgesOffset = 0;
                    nmlAttributeCounter = 0;
                    for (LOOP_VAR k = 0; k < nmlThingCounter; k++) {
                        /* write parameters */
                        if ((iParameterDone == 0) && (nmlParameterCounter > 0)) {
                            fprintf(fileOutput, "  <parameters>\n");
                            for (LOOP_VAR i = 0; i < nmlParameterCounter; i++) {
                                if (strcmp(pParameterName[i], "activeNode") == 0) {
                                    /* ignore active node */
                                    for (LOOP_VAR j = 0; j < iNumberOfParameterAttributes[i]; j++) {
                                        nmlAttributeCounter++;
                                    }
                                } else {
                                    fprintf(fileOutput, "    <%s", pParameterName[i]);
                                    for (LOOP_VAR j = 0; j < iNumberOfParameterAttributes[i]; j++) {
                                        fprintf(fileOutput, " %s=\"%s\"", pParameterAttributeName[nmlAttributeCounter], pParameterAttributeValue[nmlAttributeCounter]);
                                        nmlAttributeCounter++;
                                    }
                                    fprintf(fileOutput, "/>\n" );
                                }
                            }
                            fprintf(fileOutput, "  </parameters>\n");
                            iParameterDone = 1;
                        }
                        /* write nodes and edges */
                        if (iNumberOfNodesThing[k] > 0) {
                            /* write thing id and name */
                            if (pThingName[k]) {
                                fprintf(fileOutput, "  <thing id=\"%ld\" name=\"%s\">\n", nmlThingCounterAllFiles - nmlThingCounter + k + 1, pThingName[k]);
                            } else {
                                fprintf(fileOutput, "  <thing id=\"%ld\">\n", nmlThingCounterAllFiles - nmlThingCounter + k + 1);
                            }
                            if (bNodeIdConversionFastMode == 1) {
                                /* initialize node id conversion */
                                for (LOOP_VAR i = 0; i < MAX_NUMBER_OF_NODES; i++) {
                                    iNodeIdConversion[i] = 0;
                                }
                                /* calculate node id conversion */
                                for (LOOP_VAR i = 0; i < iNumberOfNodesThing[k]; i++) {
                                    /* convert node id */
                                    iNodeIdConversion[(int)dNode[iNumberOfNodesOffset + i][0]] = i + 1;
                                }
                            }
                            /* nodes */
                            fprintf(fileOutput, "    <nodes>\n");
                            for (LOOP_VAR i = 0; i < iNumberOfNodesThing[k]; i++) {
                                fprintf(fileOutput, "      <node");
                                for (LOOP_VAR j = 0; j < NUM_OF_NODE_ATTRIBUTES_ALL; j++) {
                                    /* comment attribute not available */
                                    if (strcmp(nmlNodeAttributes[j], "comment") == 0) {
                                        continue;
                                    }
                                    /* get id */
                                    if (j == 0) {
                                        fprintf(fileOutput, " %s=\"%d\"", nmlNodeAttributes[j], (int)dNode[iNumberOfNodesOffset + i][j]);
                                    } else {
                                        fprintf(fileOutput, ((j == 1) ? " %s=\"%.1f\"" : " %s=\"%.0f\""), nmlNodeAttributes[j], dNode[iNumberOfNodesOffset + i][j]);
                                    }
                                }
                                fprintf(fileOutput, "/>\n");
                            }
                            fprintf(fileOutput, "    </nodes>\n");
                            /* edges */
                            fprintf(fileOutput, "    <edges>\n");
                            for (LOOP_VAR i = 0; i < iNumberOfEdgesThing[k]; i++) {
                                fprintf(fileOutput, "      <edge");
                                for (LOOP_VAR j = 0; j < NUM_OF_EDGE_ATTRIBUTES; j++) {
                                    /* write node ids for edges */
                                    fprintf(fileOutput, " %s=\"%d\"", nmlEdgeAttributes[j], iEdge[iNumberOfEdgesOffset + i][j]);
                                }
                                fprintf(fileOutput, "/>\n");
                            }
                            fprintf(fileOutput, "    </edges>\n");
                            fprintf(fileOutput, "  </thing>\n");
                        } else {
                            /* no data in selection => decrease thing counter */
                            --nmlThingCounterAllFiles;
                        }
                        /* calculate nodes offset and edges offset */
                        iNumberOfNodesOffset += iNumberOfNodesThing[k];
                        iNumberOfEdgesOffset += iNumberOfEdgesThing[k];
                    }
                }
                #if !defined(__linux__) && !defined(__APPLE__)
                    iNextFileSelectMode = FindNextFile(fileHandle, &windowsFindData);
                    /* check if next file is identical with output file */
                    if (iNextFileSelectMode) {
                        if ((iListComments != 0) || (iSelectMode != 0)) {
                            if (!(windowsFindData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY))
                            {
                                /* check length of filename */
                                if (strlen(windowsFindData.cFileName) > MAX_LENGTH_FILENAME) {
                                    FindClose(fileHandle);
                                    mexErrMsgIdAndTxt("Braintracing:parseNML:FilenameTooLong", "Filename too long. Increasing MAX_LENGTH_FILENAME in the source code might help.");
                                    return;
                                }
                                /* copy filename */
                                if ((szPathAndFilename[strlen(szPathAndFilename) - 1] != '\\') && (szPathAndFilename[strlen(szPathAndFilename) - 1] != '/')) {
                                    sprintf(szPathAndFilenameCommentFiles, "%s\\%s", szPathAndFilename, windowsFindData.cFileName); /* add slash and extension */
                                } else {
                                    sprintf(szPathAndFilenameCommentFiles, "%s%s", szPathAndFilename, windowsFindData.cFileName);
                                }
                                /* compare filenames */
                                if (stricmp(szPathAndFilenameCommentFiles, szPathAndFilenameOutput) == 0) {
                                    /* skip file and get the next one */
                                    iNextFileSelectMode = FindNextFile(fileHandle, &windowsFindData);
                                }
                            }
                        }
                    }
                #endif
            }
        /* end of do loop (will only be repeated if parameter "selectMode" is 1) */
        } while (iNextFileSelectMode);

        /* ###################################################################### */
        /* #########              CREATE MATLAB CELL            ################# */
        /* ###################################################################### */
        /* check number of things */
        if (nmlThingCounter == 0) {
            mexErrMsgIdAndTxt("Braintracing:parseNML:things", "No things found.");
            return;
        }

        if ((iSelectMode == 0) || (nlhs != 0)) {
            /* set cell and create keys for parameters, commentString usw. */
            /* first thing with parameters, commentString, branchpointsString and branchpoints */
            nmlCell = mxCreateCellMatrix (1, nmlThingCounter);
    /* TEST        if (iSelectMode == 0) {*/
            nmlStruct[0] = mxCreateStructMatrix (1, 1, sizeof(nmlStructFirstThing) / sizeof(nmlStructFirstThing[0]), nmlStructFirstThing);
            mxSetCell (nmlCell, 0, nmlStruct[0]);
            /* other things only with nodes, nodesAsStruct, nodesNumDataAll, edges and thingID */
            if (nmlThingCounter > 1) {
                for (LOOP_VAR k = 1; k < (nmlThingCounter - 1); k++) {
                    nmlStruct[k] = mxCreateStructMatrix (1, 1, sizeof(nmlStructOtherThings) / sizeof(nmlStructOtherThings[0]), nmlStructOtherThings);
                    mxSetCell (nmlCell, k, nmlStruct[k]);
                }
                /* last thing with commentsString (due to writeKnossosNml.m) */
                k = nmlThingCounter - 1;
                nmlStruct[k] = mxCreateStructMatrix (1, 1, sizeof(nmlStructLastThing) / sizeof(nmlStructLastThing[0]), nmlStructLastThing);
                mxSetCell (nmlCell, k, nmlStruct[k]);
            }
    /* TEST       } else {
                for (LOOP_VAR k = 0; k < nmlThingCounter; k++) {
                    if (iNumberOfNodesThing[k] > 0) {
                        nmlStruct[k] = mxCreateStructMatrix (1, 1, sizeof(nmlStructOtherThings) / sizeof(nmlStructOtherThings[0]), nmlStructOtherThings);
                        mxSetCell (nmlCell, k, nmlStruct[k]);
                    }
                }
            } */

            /* --> PARAMETERS <-- */
            /* store parameters in matlab array */
            if ((nmlParameterCounter > 0) && (iSelectMode == 0)) {
                nmlParameterElementStruct = mxCreateStructMatrix (1, 1, nmlParameterCounter, (const char **)pParameterName);
                nmlAttributeCounter = 0;
                for (LOOP_VAR i = 0; i < nmlParameterCounter; i++) {
                    nmlParameterAttributeStruct = mxCreateStructMatrix (1, 1, iNumberOfParameterAttributes[i], (const char **)&pParameterAttributeName[nmlAttributeCounter]);
                    for (LOOP_VAR j = 0; j < iNumberOfParameterAttributes[i]; j++) {
                        mxSetFieldByNumber (nmlParameterAttributeStruct, 0, j, mxCreateString (pParameterAttributeValue[nmlAttributeCounter]));
                        nmlAttributeCounter++;
                    }
                    mxSetFieldByNumber (nmlParameterElementStruct, 0, i, nmlParameterAttributeStruct);
                }
                mxSetField (nmlStruct[0], 0, "parameters", nmlParameterElementStruct);
            }

            /* --> THINGS <-- */
            iNumberOfNodesOffset = 0;
            for (LOOP_VAR k = 0; k < nmlThingCounter; k++) {
                /* store thing id */
                if ((iSelectMode == 0) || (iNumberOfNodesThing[k] > 0)) {
                    mxSetField (nmlStruct[k], 0, "thingID", mxCreateDoubleScalar (dThingID[k]));
                }
                if (bNodeIdConversionFastMode == 1) {
                    /* initialize node id conversion */
                    for (LOOP_VAR i = 0; i < MAX_NUMBER_OF_NODES; i++) {
                        iNodeIdConversion[i] = 0;
                    }
                }

                /* store thing name (not in select mode because the name is not kept in memory) */
                if (iSelectMode == 0) {
                    if (pThingName[k]) {
                        mxSetField (nmlStruct[k], 0, "name", mxCreateString (pThingName[k]));
                    }
                }

                /* --> NODES <-- */
                /* store nodes in matlab array: Nodes and NodesNumDataAll */
                if (iNumberOfNodesThing[k] > 0) {
                    if (bNodeIdConversionFastMode == 1) {
                        /* calculate node id conversion */
                        for (LOOP_VAR i = 0; i < iNumberOfNodesThing[k]; i++) {
                            /* convert node id */
                            iNodeIdConversion[(int)dNode[iNumberOfNodesOffset + i][0]] = i + 1;
                        }
                    }

                    /* ---------------------------------------------------------------- */
                    /* Nodes */
                    nmlArrayNodes[k] = mxCreateDoubleMatrix (iNumberOfNodesThing[k], NUM_OF_NODE_ATTRIBUTES, mxREAL);
                    pArrayNodes = mxGetPr(nmlArrayNodes[k]);
                    mwPointer = 0;
                    for (LOOP_VAR j = 0; j < NUM_OF_NODE_ATTRIBUTES; j++) {
                        for (LOOP_VAR i = 0; i < iNumberOfNodesThing[k]; i++) {
                            *(pArrayNodes + mwPointer) = dNode[iNumberOfNodesOffset + i][nmlNodeAttributeOrder[j]];
                            mwPointer++;
                        }
                    }
                    /* set Nodes */
                    mxSetField (nmlStruct[k], 0, "nodes", nmlArrayNodes[k]);
                    /* ---------------------------------------------------------------- */
                    /* NodesNumDataAll */
                    nmlArrayNodesNumDataAll[k] = mxCreateDoubleMatrix (iNumberOfNodesThing[k], (NUM_OF_NODE_ATTRIBUTES_ALL - 1), mxREAL); /* ignore last column (comment) */
                    pArrayNodesNumDataAll = mxGetPr(nmlArrayNodesNumDataAll[k]);
                    mwPointer = 0;
                    for (LOOP_VAR j = 0; j < (NUM_OF_NODE_ATTRIBUTES_ALL - 1); j++) { /* ignore last column (comment) */
                        /* ignore inactive attributes and insert zero */
                        if (!iIsActive[j]) {
                            for (LOOP_VAR i = 0; i < iNumberOfNodesThing[k]; i++) {
                                *(pArrayNodesNumDataAll + mwPointer) = 0;
                                mwPointer++;
                            }
                            continue;
                        }
                        for (LOOP_VAR i = 0; i < iNumberOfNodesThing[k]; i++) {
                            *(pArrayNodesNumDataAll + mwPointer) = dNode[iNumberOfNodesOffset + i][j];
                            mwPointer++;
                        }
                    }
                    /* set NodesNumDataAll */
                    mxSetField (nmlStruct[k], 0, "nodesNumDataAll", nmlArrayNodesNumDataAll[k]);
                    /* ----------------------------------------------------------------------- */
                    /* NodesAsStruct */
                    if (iKeepNodeAsStruct) {
                        /* define dimensions of the cell/struct 'nodesAsStruct' */
                        iDimensionsNodes[0] = 1;
                        iDimensionsNodes[1] = iNumberOfNodesThing[k];
                        if (iNodesAsStructIsCell) {
                            /* provide 'nodesAsStruct' property as cell */
                            nmlCellNodeAsStruct[k] = mxCreateCellArray (2, iDimensionsNodes);
                            for (LOOP_VAR i = 0; i < iNumberOfNodesThing[k]; i++) {
                                nmlStructNodeAsStruct[iNumberOfNodesOffset + i] = mxCreateStructMatrix (1, 1, NUM_OF_NODE_ATTRIBUTES_ALL, nmlNodeAttributes);
                                mxSetCell (nmlCellNodeAsStruct[k], i, nmlStructNodeAsStruct[iNumberOfNodesOffset + i]);
                                for (LOOP_VAR j = 0; j < NUM_OF_NODE_ATTRIBUTES_ALL; j++) {
                                    /* ignore inactive attributes */
                                    if (!iIsActive[j]) {
                                        continue;
                                    }
                                    /* process attribute */
                                    if (strcmp(nmlNodeAttributes[j], "comment") == 0) {
                                           p = pNodeComment[iNumberOfNodesOffset + i];
                                    } else if (j < NUM_OF_NODE_ATTRIBUTES_NML_FILE) {
                                        if ((dNodeCoordinateOffset != 0) && (iIsCoordinate[j])) {
                                            /* convert double value into string (if offset has to be added otherwise use string from .nml file) */
                                            sprintf(szValueBuffer, "%.0f", dNode[iNumberOfNodesOffset + i][j]);
                                            p = szValueBuffer;
                                        } else {
                                            p = pNode[iNumberOfNodesOffset + i][j];
                                        }
                                    }
                                    mxSetFieldByNumber (nmlStructNodeAsStruct[iNumberOfNodesOffset + i], 0, j, mxCreateString (p));
                                }
                            }
                        } else {
                            /* provide 'nodesAsStruct' property as struct */
                            nmlCellNodeAsStruct[k] = mxCreateStructMatrix(iDimensionsNodes[0], iDimensionsNodes[1],
                                                                            NUM_OF_NODE_ATTRIBUTES_ALL, nmlNodeAttributes);
                            for (LOOP_VAR i = 0; i < iNumberOfNodesThing[k]; i++) {
                                for (LOOP_VAR j = 0; j < NUM_OF_NODE_ATTRIBUTES_ALL; j++) {
                                    /* ignore inactive attributes */
                                    if (!iIsActive[j]) {
                                        continue;
                                    }
                                    if (strcmp(nmlNodeAttributes[j], "comment") == 0) {
                                        p = pNodeComment[iNumberOfNodesOffset + i];
                                    } else if (j < NUM_OF_NODE_ATTRIBUTES_NML_FILE) {
                                        if ((dNodeCoordinateOffset != 0) && (iIsCoordinate[j])) {
                                            /* convert double value into string (if offset has to be added otherwise use string from .nml file) */
                                            sprintf(szValueBuffer, "%.0f", dNode[iNumberOfNodesOffset + i][j]);
                                            p = szValueBuffer;
                                        } else {
                                            p = pNode[iNumberOfNodesOffset + i][j];
                                        }
                                    }
                                    mxSetFieldByNumber (nmlCellNodeAsStruct[k], i, j, mxCreateString (p));
                                }
                            }
                        }
                        /* set nodesAsStruct */
                        mxSetField (nmlStruct[k], 0, "nodesAsStruct", nmlCellNodeAsStruct[k]);
                    }
                }
                /* --> EDGES <-- */
                /* store edges in matlab array */

                if (iNumberOfEdgesThing[k] > 0) {
                    /* ---------------------------------------------------------------- */
                    /* Edges */
                    if (iSelectMode == 0) {
                        nmlArrayEdges[k] = mxCreateDoubleMatrix (iNumberOfEdgesThing[k], NUM_OF_EDGE_ATTRIBUTES, mxREAL);
                        pArrayEdges = mxGetPr(nmlArrayEdges[k]);
                        mwPointer = 0;
                        for (LOOP_VAR j = 0; j < NUM_OF_EDGE_ATTRIBUTES; j++) {
                            for (LOOP_VAR i = 0; i < iNumberOfEdgesThing[k]; i++) {
                                /* calculate node ids */
                                if (bNodeIdConversionFastMode == 1) {
                                    iNodeIDConverted = iNodeIdConversion[iEdge[iNumberOfEdgesOffset + i][j]];
                                } else {
                                    /* search for node */
                                    iNodeIDConverted = 0;
                                    m = 0;
                                    d = (double)iEdge[iNumberOfEdgesOffset + i][j];
                                    while (m < iNumberOfNodesThing[k]) {
                                        if (dNode[iNumberOfNodesOffset + m][0] == d) {
                                            iNodeIDConverted = m + 1;
                                            break;
                                        }
                                        ++m;
                                    }
                                }
                                /* check node converted id and warn if node id is not available */
                                if (iNodeIDConverted == 0) {
                                    if (iListComments == 0) {
                                        printf("WARNING: Node ID %d is missing. Created incomplete edge pointing to 0.\n", iEdge[iNumberOfEdgesOffset + i][j]);
                                    }
                                }
                                *(pArrayEdges + mwPointer) = (double)iNodeIDConverted;
                                mwPointer++;
                            }
                        }
                        /* calculate edges offset */
                        iNumberOfEdgesOffset += iNumberOfEdgesThing[k];
                    } else {
                        /* count edges */
                        iNumberOfEdgesSelected = 0;
                        for (LOOP_VAR i = 0; i < iNumberOfEdgesThing[k]; i++) {
                            if (bNodeIdConversionFastMode == 1) {
                                /* calculate node ids */
                                if ((iNodeIdConversion[iEdge[iNumberOfEdgesOffset + i][0]] != 0) && (iNodeIdConversion[iEdge[iNumberOfEdgesOffset + i][1]] != 0)) {
                                    ++iNumberOfEdgesSelected;
                                } else {
                                    /* set first nodes of the edge to zero (for recognition in the following loop) */
                                    iNodeIdConversion[iEdge[iNumberOfEdgesOffset + i][0]] = 0;                            
                                }
                            } else {
                                /* search for node */
                                iNodeIdConversion[i] = 0;
                                iNodeIDConverted = 0;
                                m = 0;
                                d = (double)iEdge[iNumberOfEdgesOffset + i][0];
                                while (m < iNumberOfNodesThing[k]) {
                                    if (dNode[iNumberOfNodesOffset + m][0] == d) {
                                        iNodeIDConverted = m + 1;
                                        break;
                                    }
                                    ++m;
                                }
                                if (iNodeIDConverted > 0) {
                                    iNodeIDConverted = 0;
                                    m = 0;
                                    d = (double)iEdge[iNumberOfEdgesOffset + i][1];
                                    while (m < iNumberOfNodesThing[k]) {
                                        if (dNode[iNumberOfNodesOffset + m][0] == d) {
                                            iNodeIDConverted = m + 1;
                                            break;
                                        }
                                        ++m;
                                    }
                                    /* both nodes were found */
                                    if (iNodeIDConverted > 0)
                                    {
                                        iNodeIdConversion[i] = 1;
                                        ++iNumberOfEdgesSelected;
                                    }
                                }
                            }
                        }
                        nmlArrayEdges[k] = mxCreateDoubleMatrix (iNumberOfEdgesSelected, NUM_OF_EDGE_ATTRIBUTES, mxREAL);
                        pArrayEdges = mxGetPr(nmlArrayEdges[k]);
                        mwPointer = 0;
                        if (bNodeIdConversionFastMode == 1) {
                            for (LOOP_VAR j = 0; j < NUM_OF_EDGE_ATTRIBUTES; j++) {
                                for (LOOP_VAR i = 0; i < iNumberOfEdgesThing[k]; i++) {
                                    if (iNodeIdConversion[iEdge[iNumberOfEdgesOffset + i][0]] != 0) {
                                        /* calculate node ids */
                                        iNodeIDConverted = iNodeIdConversion[iEdge[iNumberOfEdgesOffset + i][j]];
                                        *(pArrayEdges + mwPointer) = (double)iNodeIDConverted;
                                        mwPointer++;
                                    }
                                }
                            }
                        } else {
                            for (LOOP_VAR j = 0; j < NUM_OF_EDGE_ATTRIBUTES; j++) {
                                for (LOOP_VAR i = 0; i < iNumberOfEdgesThing[k]; i++) {
                                    /* search for node */
                                    if (iNodeIdConversion[i] != 0) {
                                        iNodeIDConverted = 0;
                                        m = 0;
                                        d = (double)iEdge[iNumberOfEdgesOffset + i][j];
                                        while (m < iNumberOfNodesThing[k]) {
                                            if (dNode[iNumberOfNodesOffset + m][0] == d) {
                                                iNodeIDConverted = m + 1;
                                                break;
                                            }
                                            ++m;
                                        }
                                        if (iNodeIDConverted != 0) {
                                            /* calculate node ids */
                                            *(pArrayEdges + mwPointer) = (double)iNodeIDConverted;
                                            mwPointer++;
                                        }
                                    }
                                }
                            }
                        }
                        /* calculate edges offset */
                        iNumberOfEdgesOffset += iNumberOfEdgesSelected;
                    }
                    /* set edges */
                    mxSetField (nmlStruct[k], 0, "edges", nmlArrayEdges[k]);
                    /* ---------------------------------------------------------------- */
                }

                if (iNumberOfNodesThing[k] > 0) {
                    /* calculate nodes offset */
                    iNumberOfNodesOffset += iNumberOfNodesThing[k];
                }
            }

            /* --> COMMENTS <-- */
            if (bCommentsAvailable) { /* do not intialize comments string if comments are not available */
                /* create comments string for all things */
                /* save memory pointer (last position) */
                gMemorypointerCurrent = gMemorypointer;
                /* ..................................................................... */
                /* add 16 characters initialisation (is necessary for writeKnossosNml.m) */
                iLength = 16;
                /* check free memory size */
                if (iLength >= (MEMORY_SIZE - gMemorypointer - 1)) {
                    fclose (file);
                    errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
                    if (iListComments == 0) {
                        plhs[0] = mxCreateCellMatrix (1, 1);
                    }
                    return;
                }
                /* write 16 characters */
                iNumberOfBytesWritten = sprintf(&nmlMemory[gMemorypointer], "<comments>     \x0A"); /* exactly 16 characters long */
                /* check success */
                if ((iNumberOfBytesWritten < 0) || (iNumberOfBytesWritten >= (MEMORY_SIZE - gMemorypointer - 1))) {
                    fclose (file);
                    errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
                    if (iListComments == 0) {
                        plhs[0] = mxCreateCellMatrix (1, 1);
                    }
                    return;
                }
                /* adjust memory pointer */
                gMemorypointer += iNumberOfBytesWritten;
                /* .................................................................... */
                /* ------------ */
                /* add comments */
                /* ------------ */
                for (LOOP_VAR i = 0; i < nmlCommentCounter; i++) {
                    /* clear memory */
                    nmlMemory[gMemorypointer] = 0;
        /* TODO: This is a problem that should solved someday to avoid memory crash using huge files */
        /* the snprintf function was not available in the compiler ;-( */
        /*            iNumberOfBytesWritten = snprintf(&nmlMemory[gMemorypointer], MEMORY_SIZE - gMemorypointer - 1, */
        /*                "%s<comment node=\"%d\" content=\"%s\"/>", (i > 0) ? "\n" : "", iCommentNodeID[i], pCommentContent[i]); */
        /* the following solution checks memory size AFTER using it which could raise a memory violation exception in case memory isn't big enough */
                    iNumberOfBytesWritten = sprintf(&nmlMemory[gMemorypointer],
                        "%s<comment node=\"%d\" content=\"%s\"/>", (i > 0) ? "\n" : "", iCommentNodeID[i], pCommentContent[i]);
                    if ((iNumberOfBytesWritten < 0) || (iNumberOfBytesWritten >= (MEMORY_SIZE - gMemorypointer - 1))) {
                        fclose (file);
                        errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
                        if (iListComments == 0) {
                            plhs[0] = mxCreateCellMatrix (1, 1);
                        }
                        return;
                    }
                    gMemorypointer += iNumberOfBytesWritten;
                }
                /* ------------- */
                /* list comments */
                /* ------------- */
                if (iListComments != 0) {
                    for (LOOP_VAR i = 0; i < nmlCommentCounter; i++) {
                        /* print file name */
                        if (i == 0) {
                            if (szTaskId[0] == 0) {
                                /* show file name without link */
                                printf("File (task ID not found): %s\n", szPathAndFilenameCommentFiles);
                            } else {
                                /* show file name with link (for MATLAB users) */
                                printf("File: <a href=\"matlab:web('%s%s','-browser')\">%s</a>\n", URL_WEBKNOSSOS, szTaskId, szPathAndFilenameCommentFiles);
                                /* show file name with link (for other users) */
                                printf("Link: %s%s\n", URL_WEBKNOSSOS, szTaskId);
                            }
                        }
                        /* list comments */
                        if (bNodeIdConversionFastMode == 1) {
                            bNodeFound = 1;
                            iNode = iNodeIdConversionAllThings[iCommentNodeID[i]];
                        } else {
                            /* search for node */
                            bNodeFound = 0;
                            j = 0;
                            d = (double)iCommentNodeID[i];
                            while (j < iNumberOfNodes) {
                                if (dNode[j][0] == d) {
                                    bNodeFound = 1;
                                    break; /* exit while loop */
                                }
                                ++j;
                            }
                            if (bNodeFound == 1) {
                                iNode = j;
                            } else {
                                printf("WARNING: Comment refers to nonexistent node ID %d. Comment will be ignored.\n", iCommentNodeID[i]);
                            }
                        }
                        if (bNodeFound == 1)
                            printf("%s%s%sNode %d (%.0f,%.0f,%.0f): %s\n",
                                    ((szTaskId[0] == 0) ? "" : "Tracing ID: "),                                         /* additional text for task id */
                                    ((szTaskId[0] == 0) ? "" : &szTaskId[LENGTH_MONGODB_ID - LENGTH_MONGODB_ID_SHORT]), /* print task id if available  */
                                    ((szTaskId[0] == 0) ? "" : ", "),                                                   /* additional text for task id */
                                    iCommentNodeID[i], dNode[iNode][2], dNode[iNode][3], dNode[iNode][4], pCommentContent[i]);
                    }
                }
                /* ....................................................................... */
                /* add 16 characters de-initialisation (is necessary for writeKnossosNml.m) */
                iLength = 16;
                /* check free memory size */
                if (iLength >= (MEMORY_SIZE - gMemorypointer - 1)) {
                    fclose (file);
                    errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
                    if (iListComments == 0) {
                        plhs[0] = mxCreateCellMatrix (1, 1);
                    }
                    return;
                }
                /* write 16 characters */
                iNumberOfBytesWritten = sprintf(&nmlMemory[gMemorypointer], "\x0A</comments>    "); /* exactly 16 characters long */
                /* check success */
                if ((iNumberOfBytesWritten < 0) || (iNumberOfBytesWritten >= (MEMORY_SIZE - gMemorypointer - 1))) {
                    fclose (file);
                    errorMessage(SECTION_COMMENTSSTRING, ERROR_OUT_OF_MEMORY);
                    if (iListComments == 0) {
                        plhs[0] = mxCreateCellMatrix (1, 1);
                    }
                    return;
                }
                /* adjust memory pointer */
                gMemorypointer += iNumberOfBytesWritten; 
                /* ....................................................................... */
                /* write comments string if available */
                nmlCellCommentsString = mxCreateCellArray (1, iDimensions);
                mxSetCell (nmlCellCommentsString, 0, mxCreateString (&nmlMemory[gMemorypointerCurrent]));
                mxSetField (nmlStruct[0], 0, "commentsString", nmlCellCommentsString);
                /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
                /* funny extension due to writeKnossosNml.m */
                /* if there are more than one things the LAST thing has to have a commentsString cell (don't ask me why) that can be empty */
                /* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
                if (nmlThingCounter > 1) {
                    nmlCellLastCommentsString = mxCreateCellMatrix (0, 0);
                    mxSetField (nmlStruct[nmlThingCounter - 1], 0, "commentsString", nmlCellLastCommentsString);
                }
            }

            if ((iListComments != 0) && ((!bCommentsAvailable) || (nmlCommentCounter == 0))) {
                /* show filename of file without comments */
                printf("File (no comments): %s\n", szPathAndFilenameCommentFiles);
            }

            /* --> BRANCHPOINTS <-- */
            /* store branchpoints in matlab array */
            /* ------------- ATTENTION !!! --------------------------------------------------------------------------------------------------- */
            /* ----- branchpoints MUST be processed as LAST struct because they use global memory (and overwrite existing data) ! */
            /* ------------------------------------------------------------------------------------------------------------------------------- */
            /* branchpoints will ignored in select mode (because renumbering of nodes is not performed in access mode) */
            if ((iNumberOfBranchpoints > 0) && (iSelectMode == 0)) {
                /* ---------------------------------------------------------------- */
                /* list branchpoints */
                mwPointer = 0;
                nmlArrayBranchpoints = mxCreateDoubleMatrix (iNumberOfBranchpoints, NUM_OF_BRANCHPOINT_ATTRIBUTES, mxREAL);
                pArrayBranchpoints = mxGetPr(nmlArrayBranchpoints);
                for (LOOP_VAR i = 0; i < iNumberOfBranchpoints; i++) {
                    *(pArrayBranchpoints + mwPointer) = (double)iBranchpoint[i];
                    mwPointer++;
                }
                /* reset memory */
                gMemorypointer = 0;
                nmlMemory[gMemorypointer] = 0;
                for (LOOP_VAR i = 0; i < iNumberOfBranchpoints; i++) {
                    /* create string */
                    sprintf(szMessageBuffer, "<branchpoint id=\"%d\"/>%s", iBranchpoint[i], (i < (iNumberOfBranchpoints - 1)) ? "\n" : "");
                    if (strlen(szMessageBuffer) + gMemorypointer + 1 >= MEMORY_SIZE) {
                        errorMessage(SECTION_BRANCHPOINTSSTRING, ERROR_OUT_OF_MEMORY);
                        if (iListComments == 0) {
                            plhs[0] = nmlCell;
                        }
                        return;
                    }
                    for (LOOP_VAR j = 0; j < strlen(szMessageBuffer); j++) {
                        nmlMemory[gMemorypointer++] = szMessageBuffer[j];
                    }
                    /* add end mark of string (zero) */
                    nmlMemory[gMemorypointer] = 0;
                }
                /* set branchpoints */
                mxSetField (nmlStruct[0], 0, "branchpoints", nmlArrayBranchpoints);
                /* ---------------------------------------------------------------- */
                /* create branchpointString */
                nmlCellBranchpointsString = mxCreateCellArray (1, iDimensions);
                mxSetCell (nmlCellBranchpointsString, 0, mxCreateString (nmlMemory));
                mxSetField (nmlStruct[0], 0, "branchpointsString", nmlCellBranchpointsString);
                /* reset memory pointer */
                gMemorypointer = 0;
                nmlMemory[gMemorypointer] = 0;
            } else {
                /* no branchpoints: initialize branchpointsString */
                nmlCellBranchpointsString = mxCreateCellMatrix (0, 0);
                mxSetField (nmlStruct[0], 0, "branchpointsString", nmlCellBranchpointsString);
            }
        }

        if (iListComments == 0) {
            /* in default mode only one file is processed */
            iNextFile = 0;
        } else {
            #if !defined(__linux__) && !defined(__APPLE__)
                iNextFile = FindNextFile(fileHandle, &windowsFindData);
            #endif
        }
    /* end of do loop (will only be repeated if parameter "listComments" is 1)  */
    } while (iNextFile);

    /* close directory */
    if ((iListComments != 0) || (iSelectMode != 0)) {
        #if !defined(__linux__) && !defined(__APPLE__)
            FindClose(fileHandle);
        #endif
    }

    /* close output file */
    if ((iSelectMode != 0) && (nlhs == 0)) {
        /* close file */
        fprintf(fileOutput, "  <branchpoints>\n");
        fprintf(fileOutput, "  </branchpoints>\n");
        fprintf(fileOutput, "  <comments>\n");
        fprintf(fileOutput, "  </comments>\n");
        fprintf(fileOutput, "</things>\n");
        fclose(fileOutput);
    }

    /* print processing time */
    printf("Processing time: %d seconds.\n", time(NULL) - time_start);

    /* print success message */
    if (iListComments != 0) {
        printf("Comment listing finished.\n");
    } else if (iSelectMode != 0) {
        printf("Import of nodes in select mode finished.\n");
    } else {
        printf("File %s successfully imported.\n", szPathAndFilename);
    }

    /* return cell (not in "list comment" mode) */
    if (iListComments == 0) {
        plhs[0] = nmlCell;
    }
    return;
}
