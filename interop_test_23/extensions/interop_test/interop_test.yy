{
  "optionsFile": "options.json",
  "options": [],
  "exportToGame": true,
  "supportedTargets": 113497714299118,
  "extensionVersion": "1.0.0",
  "packageId": "",
  "productId": "",
  "author": "",
  "date": "2019-12-12T01:34:29",
  "license": "Proprietary",
  "description": "",
  "helpfile": "",
  "iosProps": true,
  "tvosProps": false,
  "androidProps": true,
  "installdir": "",
  "files": [
    {"filename":"interop_test.dll","origname":"extensions\\interop_test.dll","init":"","final":"","kind":1,"uncompress":false,"functions":[
        {"externalName":"iq_get_int_raw","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_int_raw","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_int64_raw","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_int64_raw","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_string_raw","kind":11,"help":"","hidden":true,"returnType":1,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_string_raw","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_vec_raw","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_vec_raw","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_vec_raw_post","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_vec_raw_post","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_struct_vec_raw","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_struct_vec_raw","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_struct_vec_raw_post","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_struct_vec_raw_post","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_two_int64s_raw","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_two_int64s_raw","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_add_int64_raw","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_add_int64_raw","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_add_two_int64s_raw","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_add_two_int64s_raw","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_int64_vec_sum_raw","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_int64_vec_sum_raw","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_buffer_sum_raw","kind":11,"help":"","hidden":true,"returnType":2,"argCount":1,"args":[
            1,
          ],"resourceVersion":"1.0","name":"iq_get_buffer_sum_raw","tags":[],"resourceType":"GMExtensionFunction",},
      ],"constants":[
        
      ],"ProxyFiles":[],"copyToTargets":9223372036854775807,"order":[
        {"name":"iq_get_int_raw","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_int64_raw","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_string_raw","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_vec_raw","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_vec_raw_post","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_struct_vec_raw","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_struct_vec_raw_post","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_two_int64s_raw","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_add_int64_raw","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_add_two_int64s_raw","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_int64_vec_sum_raw","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_buffer_sum_raw","path":"extensions/interop_test/interop_test.yy",},
      ],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
    {"filename":"interop_test.gml","origname":"extensions\\gml.gml","init":"","final":"","kind":2,"uncompress":false,"functions":[
        {"externalName":"itr_test_prepare_buffer","kind":2,"help":"itr_test_prepare_buffer(size:int)->buffer~","hidden":false,"returnType":2,"argCount":1,"args":[
            2,
          ],"resourceVersion":"1.0","name":"itr_test_prepare_buffer","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"itr_test_read_chars","kind":2,"help":"itr_test_read_chars(buffer:buffer, len:int)->string~","hidden":false,"returnType":2,"argCount":2,"args":[
            2,
            2,
          ],"resourceVersion":"1.0","name":"itr_test_read_chars","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"itr_test_write_chars","kind":11,"help":"","hidden":true,"returnType":2,"argCount":3,"args":[
            2,
            2,
            2,
          ],"resourceVersion":"1.0","name":"itr_test_write_chars","tags":[],"resourceType":"GMExtensionFunction",},
      ],"constants":[
        
      ],"ProxyFiles":[],"copyToTargets":9223372036854775807,"order":[
        {"name":"itr_test_prepare_buffer","path":"extensions/interop_test/interop_test.yy",},
        {"name":"itr_test_read_chars","path":"extensions/interop_test/interop_test.yy",},
        {"name":"itr_test_write_chars","path":"extensions/interop_test/interop_test.yy",},
      ],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
    {"filename":"autogen.gml","origname":"","init":"","final":"","kind":2,"uncompress":false,"functions":[
        {"externalName":"iq_get_int","kind":2,"help":"iq_get_int()->int","hidden":false,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"iq_get_int","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_int64","kind":2,"help":"iq_get_int64()->int","hidden":false,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"iq_get_int64","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_string","kind":2,"help":"iq_get_string()->int","hidden":false,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"iq_get_string","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_vec","kind":2,"help":"iq_get_vec()->array<int>","hidden":false,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"iq_get_vec","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_struct_vec","kind":2,"help":"iq_get_struct_vec()->array<any>","hidden":false,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"iq_get_struct_vec","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_two_int64s","kind":2,"help":"iq_get_two_int64s()->","hidden":false,"returnType":2,"argCount":0,"args":[],"resourceVersion":"1.0","name":"iq_get_two_int64s","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_add_int64","kind":2,"help":"iq_add_int64(a:int, b:int)->int","hidden":false,"returnType":2,"argCount":2,"args":[
            2,
            2,
          ],"resourceVersion":"1.0","name":"iq_add_int64","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_add_two_int64s","kind":2,"help":"iq_add_two_int64s(tup)->int","hidden":false,"returnType":2,"argCount":1,"args":[
            2,
          ],"resourceVersion":"1.0","name":"iq_add_two_int64s","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_int64_vec_sum","kind":2,"help":"iq_get_int64_vec_sum(arr:array<int>)->int","hidden":false,"returnType":2,"argCount":1,"args":[
            2,
          ],"resourceVersion":"1.0","name":"iq_get_int64_vec_sum","tags":[],"resourceType":"GMExtensionFunction",},
        {"externalName":"iq_get_buffer_sum","kind":2,"help":"iq_get_buffer_sum(buf:buffer)->int","hidden":false,"returnType":2,"argCount":1,"args":[
            2,
          ],"resourceVersion":"1.0","name":"iq_get_buffer_sum","tags":[],"resourceType":"GMExtensionFunction",},
      ],"constants":[
        
      ],"ProxyFiles":[],"copyToTargets":-1,"order":[
        {"name":"iq_get_int","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_int64","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_string","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_vec","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_struct_vec","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_two_int64s","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_add_int64","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_add_two_int64s","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_int64_vec_sum","path":"extensions/interop_test/interop_test.yy",},
        {"name":"iq_get_buffer_sum","path":"extensions/interop_test/interop_test.yy",},
      ],"resourceVersion":"1.0","name":"","tags":[],"resourceType":"GMExtensionFile",},
  ],
  "classname": "",
  "tvosclassname": "",
  "tvosdelegatename": "",
  "iosdelegatename": "",
  "androidclassname": "",
  "sourcedir": "",
  "androidsourcedir": "",
  "macsourcedir": "",
  "maccompilerflags": "",
  "tvosmaccompilerflags": "",
  "maclinkerflags": "",
  "tvosmaclinkerflags": "",
  "iosplistinject": "",
  "tvosplistinject": "",
  "androidinject": "",
  "androidmanifestinject": "",
  "androidactivityinject": "",
  "gradleinject": "",
  "iosSystemFrameworkEntries": [],
  "tvosSystemFrameworkEntries": [],
  "iosThirdPartyFrameworkEntries": [],
  "tvosThirdPartyFrameworkEntries": [],
  "IncludedResources": [],
  "androidPermissions": [],
  "copyToTargets": 113497714299118,
  "iosCocoaPods": "",
  "tvosCocoaPods": "",
  "iosCocoaPodDependencies": "",
  "tvosCocoaPodDependencies": "",
  "parent": {
    "name": "Extensions",
    "path": "folders/Extensions.yy",
  },
  "resourceVersion": "1.2",
  "name": "interop_test",
  "tags": [],
  "resourceType": "GMExtension",
}