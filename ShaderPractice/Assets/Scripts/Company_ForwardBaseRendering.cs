using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Company_ForwardBaseRendering : MonoBehaviour
{

	public Transform directionalLight;
	public Transform pointLight;

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		directionalLight.Rotate(Vector3.up,4f * Time.deltaTime);
		
	}
}
