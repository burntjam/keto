/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   Constants.hpp
 * Author: ubuntu
 *
 * Created on March 12, 2018, 11:02 AM
 */

#ifndef ASN1_CONSTANTS_HPP
#define ASN1_CONSTANTS_HPP

namespace keto {
namespace asn1 {

class
Constants {
public:
    
    static constexpr const char* RDF_LANGUAGE = "en";
    class RDF_NODE {
    public:
        static constexpr const char* LITERAL = "literal";
        static constexpr const char* URI = "uri";
    };
    
    
};


}
}


#endif /* CONSTANTS_HPP */

