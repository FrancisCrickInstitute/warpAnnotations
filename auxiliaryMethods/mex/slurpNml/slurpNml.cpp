/*
Slurp NML - A Minimalistic NML Parser

Written by
  alessandro.motta@brain.mpg.de
  benedikt.staffler@brain.mpg.de

Tested with
  MATLAB R2015b on 64-bit Windows
  Compiled with Microsoft Visual Studio 2015

  MATLAB R2015b on 64-bit Linux
  Compiled with GCC 4.7 and GCC 4.9

Vim configuration
  vim: set tabstop=4 shiftwidth=4 expandtab:
*/

#include <array>
#include <cmath>
#include <iterator>
#include <string>
#include <vector>
#include <stdint.h> 

#include "mex.h"
#include "pugixml.hpp"

typedef enum {
    NML_DOUBLE,
    NML_BOOL,
    NML_STRING,
    NML_MANUAL
} nml_type;

typedef struct {
    std::string name;
    nml_type type;
} nml_attribute;

const std::array<nml_attribute, 9> nml_thing_obj = {{
    {"id",      NML_DOUBLE},
    {"color.r", NML_DOUBLE},
    {"color.g", NML_DOUBLE},
    {"color.b", NML_DOUBLE},
    {"color.a", NML_DOUBLE},
    {"name",    NML_STRING},
    {"nodes",   NML_MANUAL},
    {"edges",   NML_MANUAL},
    {"groupId", NML_DOUBLE}
}};

const std::array<nml_attribute, 2> nml_group_obj = {{
    {"name",        NML_STRING},
    {"id",          NML_DOUBLE}
}};
    

const std::array<nml_attribute, 10> nml_node_obj = {{
    {"id",            NML_DOUBLE},
    {"x",             NML_DOUBLE},
    {"y",             NML_DOUBLE},
    {"z",             NML_DOUBLE},
    {"radius",        NML_DOUBLE},
    {"inVp",          NML_DOUBLE},
    {"inMag",         NML_DOUBLE},
    {"bitDepth",      NML_DOUBLE},
    {"interpolation", NML_BOOL  },
    {"time",          NML_DOUBLE}
}};

const std::array<nml_attribute, 2> nml_edge_obj = {{
    {"source", NML_DOUBLE},
    {"target", NML_DOUBLE}
}};

const std::array<nml_attribute, 1> nml_branchpoint_obj = {{
    {"id", NML_DOUBLE}
}};

const std::array<nml_attribute, 2> nml_comment_obj = {{
    {"node",    NML_DOUBLE},
    {"content", NML_STRING}
}};

/* This function builds a list with the names of all NML
   attributes. It uses C strings in order to be compatible
   with the MEX API. */
template <std::size_t N>
void get_attr_names(const std::array<nml_attribute, N> & nml_obj,
                    std::array<const char *, N> & names){
    for(auto idx = 0; idx < N; idx++){
        /* get names in C form */
        names[idx] = nml_obj[idx].name.c_str();
    }
}

void prepare_struct_field(const size_t nml_obj_count,
                          const nml_type type,
                          mxArray ** out){
    mxArray * arr;
    switch(type){
        case NML_DOUBLE:
            arr = mxCreateNumericMatrix(
                nml_obj_count, 1, mxDOUBLE_CLASS, mxREAL);
            break;

        case NML_BOOL:
            arr = mxCreateNumericMatrix(
                nml_obj_count, 1, mxUINT8_CLASS, mxREAL);
            break;

        case NML_STRING:
        case NML_MANUAL:
            arr = mxCreateCellMatrix(
                nml_obj_count, 1);
            break;
    }

    /* set output */
    *out = arr;
}

template <std::size_t N>
void prepare_struct(const std::array<nml_attribute, N> & nml_obj,
                    const size_t nml_obj_count,
                    mxArray ** out){
    /* get attribute names */
    std::array<const char *, N> attr_names;
    get_attr_names(nml_obj, attr_names);

    /* prepare output */
    mxArray * arr = mxCreateStructMatrix(
        1, 1, N, attr_names.data());

    /* prepare fields */
    for(auto idx = 0; idx < N; idx++){
        mxArray * field_arr;

        /* prepare field */
        auto type = nml_obj[idx].type;
        prepare_struct_field(nml_obj_count, type, &field_arr);

        /* set field */
        mxSetFieldByNumber(arr, 0, idx, field_arr);
    }

    /* set output */
    *out = arr;
}

inline
void parse_nml_double(const pugi::xml_attribute & xml_attr,
                      const size_t xml_idx,
                      mxArray * arr){
    auto val = xml_attr.as_double(NAN);
    auto ptr = (double *) mxGetPr(arr);

    /* set field */
    ptr[xml_idx] = val;
}

inline
void parse_nml_bool(const pugi::xml_attribute & xml_attr,
                    const size_t xml_idx,
                    mxArray * arr){
    auto val = (uint8_t) xml_attr.as_bool(false);
    auto ptr = (uint8_t *) mxGetPr(arr);

    /* set field */
    ptr[xml_idx] = val;
}

inline
void parse_nml_string(const pugi::xml_attribute & xml_attr,
                      const size_t xml_idx,
                      mxArray * arr){
    auto val = xml_attr.value();
    auto val_arr = mxCreateString(val);

    /* set field */
    mxSetCell(arr, xml_idx, val_arr);
}

inline
void parse_nml_attr(const pugi::xml_node & xml_node,
                    const size_t xml_idx,
                    const nml_attribute & nml_attr,
                    mxArray * arr){
    auto attr_type = nml_attr.type;
    auto attr_name = nml_attr.name.c_str();

    /* get attribute */
    auto xml_attr = xml_node.attribute(attr_name);

    switch(attr_type){
        case NML_DOUBLE:
            parse_nml_double(xml_attr, xml_idx, arr);
            break;

        case NML_BOOL:
            parse_nml_bool(xml_attr, xml_idx, arr);
            break;

        case NML_STRING:
            parse_nml_string(xml_attr, xml_idx, arr);
            break;

        case NML_MANUAL:
            // nothing
            break;
    }
}

template <std::size_t N> inline
void parse_nml_object(const pugi::xml_node & xml_obj,
                      const size_t xml_idx,
                      const std::array<nml_attribute, N> & nml_obj,
                      mxArray * arr){
    /* iterate over attributes */
    for(auto attr_idx = 0; attr_idx < N; attr_idx++){
        auto attr = nml_obj[attr_idx];

        /* get field pointer */
        auto field_arr = mxGetFieldByNumber(arr, 0, attr_idx);
        parse_nml_attr(xml_obj, xml_idx, attr, field_arr);
    }
}

template <std::size_t N>
void parse_nml_objects(const pugi::xml_object_range<pugi::xml_named_node_iterator> & xml_iter,
                       const std::array<nml_attribute, N> & nml_obj,
                       mxArray ** out){
    /* count attributes and XML nodes */
    auto num_attrs = N;
    auto num_objs = std::distance(xml_iter.begin(), xml_iter.end());

    /* prepare struct fields */
    mxArray * arr;
    prepare_struct(nml_obj, num_objs, &arr);

    /* read NML */
    size_t xml_idx = 0;
    for(auto & xml_node : xml_iter){
        /* pare current object */
        parse_nml_object(xml_node, xml_idx, nml_obj, arr);

        /* go to next row */
        xml_idx++;
    }

    *out = arr;
}

void parse_nml_things(const pugi::xml_object_range<pugi::xml_named_node_iterator> & xml_things,
                      mxArray ** out){
    /* parse things */
    mxArray * arr;
    parse_nml_objects(xml_things, nml_thing_obj, &arr);

    auto nodes_arr = mxGetField(arr, 0, "nodes");
    auto edges_arr = mxGetField(arr, 0, "edges");

    size_t xml_idx = 0;
    for(auto & xml_thing : xml_things){
        /* parse nodes */
        mxArray * cur_nodes_arr;
        parse_nml_objects(
            xml_thing.child("nodes").children("node"),
            nml_node_obj, &cur_nodes_arr);

        /* parse edges */
        mxArray * cur_edges_arr;
        parse_nml_objects(
            xml_thing.child("edges").children("edge"),
            nml_edge_obj, &cur_edges_arr);

        /* set nodes */
        mxSetCell(nodes_arr, xml_idx, cur_nodes_arr);
        mxSetCell(edges_arr, xml_idx, cur_edges_arr);

        /* go to next row */
        xml_idx++;
    }

    /* set output */
    *out = arr;
}

void parse_nml_parameter_values(const pugi::xml_node & xml_param,
                                mxArray ** out){
    auto xml_attrs = xml_param.attributes();
    auto xml_attr_count = std::distance(
        xml_attrs.begin(), xml_attrs.end());

    /* get attributes */
    std::vector<const char *> attr_names(xml_attr_count);
    std::vector<mxArray *> attr_values(xml_attr_count);

    size_t idx = 0;
    for(auto & xml_attr : xml_attrs){
        attr_names[idx] = xml_attr.name();
        attr_values[idx] = mxCreateString(xml_attr.value());
        
        idx++;    
    }

    /* to MATLAB */
    mxArray * arr = mxCreateStructMatrix(
        1, 1, xml_attr_count, attr_names.data());

    for(idx = 0; idx < xml_attr_count; idx++){
        mxSetFieldByNumber(arr, 0, idx, attr_values[idx]);
    }

    /* set output */
    *out = arr;
}

void parse_nml_parameters(const pugi::xml_node & xml_params,
                          mxArray ** out){
    auto xml_param_nodes = xml_params.children();
    auto xml_param_count = std::distance(
        xml_param_nodes.begin(), xml_param_nodes.end());

    /* get all child names and their values */
    std::vector<const char *> param_names(xml_param_count);
    std::vector<mxArray *> param_arrs(xml_param_count);

    size_t idx = 0;
    for(auto & xml_param : xml_param_nodes){
        param_names[idx] = xml_param.name();
        parse_nml_parameter_values(xml_param, &param_arrs[idx]);

        /* go to next row */    
        idx++;
    }

    /* to MATLAB */
    mxArray * arr = mxCreateStructMatrix(
        1, 1, xml_param_count, param_names.data());

    for(idx = 0; idx < xml_param_count; idx++){
        mxSetFieldByNumber(arr, 0, idx, param_arrs[idx]);
    }

    /* set output */
    *out = arr;
}

void parse_nml_groups(const pugi::xml_object_range<pugi::xml_named_node_iterator> xml_groups,
                      mxArray ** out){
    auto nml_obj = nml_group_obj;
    auto num_objects = std::distance(xml_groups.begin(), xml_groups.end());
    mxArray * arr;
    prepare_struct(nml_obj, num_objects, &arr);
    
    /* add additional field for children */
    mxAddField(arr, "children");
    mxSetField(arr, 0, "children", mxCreateCellMatrix(num_objects, 1));
    
    int i = 0;
    for (auto & xml_group : xml_groups){
        parse_nml_object(xml_group, i, nml_obj, arr);
        
        if (xml_group.first_child() != NULL){
            mxArray * thisChild;
            parse_nml_groups(xml_group.children("group"), &thisChild);
            mxArray * childrenField = mxGetField(arr, 0, "children");
            mxSetCell(childrenField, i, thisChild);
        }
        i++;
    }
    *out = arr;
}

void parse_nml(const pugi::xml_document & xml_doc,
               mxArray ** out){
    
    std::array<const char *, 5> field_names = {{
        "parameters",
        "things",
        "branchpoints",
        "comments",
        "groups"
    }};

    /* prepare structure */
    mxArray * arr = mxCreateStructMatrix(
        1, 1, field_names.size(), field_names.data());

    /* get XML things */
    auto xml_things = xml_doc.child("things");

    /* parse things */
    mxArray * things_arr;
    parse_nml_things(xml_things.children("thing"), &things_arr);

    /* parse parameters */
    mxArray * params_arr;
    parse_nml_parameters(xml_things.child("parameters"), &params_arr);

    /* parse branchpoints */
    mxArray * branchpoints_arr;
    parse_nml_objects(
        xml_things.child("branchpoints").children("branchpoint"),
        nml_branchpoint_obj, &branchpoints_arr);

    /* parse comments */
    mxArray * comments_arr;
    parse_nml_objects(
        xml_things.child("comments").children("comment"),
        nml_comment_obj, &comments_arr);
    
    /* parse groups */
    mxArray * groups_arr;
    parse_nml_groups(
        xml_things.child("groups").children("group"),
            &groups_arr);

    /* set results */
    mxSetField(arr, 0, "parameters", params_arr);
    mxSetField(arr, 0, "things", things_arr);
    mxSetField(arr, 0, "branchpoints", branchpoints_arr);
    mxSetField(arr, 0, "comments", comments_arr);
    mxSetField(arr, 0, "groups", groups_arr);

    /* set output */
    *out = arr;
}

void mexFunction(int nlhs, mxArray * plhs[],
                 int nrhs, const mxArray * prhs[]){
    /* check for file name */
    if(nrhs < 1 || !mxIsChar(prhs[0])){
        mexErrMsgTxt("No NML file specified...");
        return;
    }

    /* get file name */
    const char * file_name = mxArrayToString(prhs[0]);

    /* load document */
    pugi::xml_document xml_doc;
    pugi::xml_parse_result res = xml_doc.load_file(file_name);

    if(!res){
        mexErrMsgTxt("Could not load file");
    }

    /* parse NML */
    parse_nml(xml_doc, &plhs[0]);
}

