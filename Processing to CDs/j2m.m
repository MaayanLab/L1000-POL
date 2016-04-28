function [ matlabObj ] = j2m( javaObj )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

matlabObj = loadjson(char(javaObj.toString));
end

